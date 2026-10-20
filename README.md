# Cloud-1

Automated deployment of a fully dockerized WordPress stack (nginx, WordPress, phpMyAdmin, MariaDB) on AWS EC2, provisioned with Terraform and configured with Ansible. One command takes you from an empty AWS account section to a WordPress site served over HTTPS, and the same playbooks can target several servers at once.

This project is the cloud follow-up to Inception. The Docker application itself (one process per container, custom images, nginx, php-fpm, MariaDB) is documented here: <https://github.com/NabilHY/inception-42.git>. This README covers what is new in Cloud-1: provisioning, automation, secrets, TLS, and multi-server deployment.

---

## 1. What this project does

- Provisions an EC2 instance with Terraform and attaches a pre-allocated Elastic IP to it.
- Configures a bare Ubuntu 22.04 host with Ansible: system prep, firewall, Docker, the compose stack, and a Let's Encrypt certificate.
- Runs the application as four containers on one internal Docker network. Only nginx publishes ports (80 and 443).
- Keeps the site alive across reboots (`restart: always`) and keeps its data (named volumes for the database and the WordPress files).
- Stores every secret encrypted with Ansible Vault, so the repository can be committed safely with a single vault password as the only thing kept out of it.
- Can be run against several servers in one execution.

## 2. Architecture

```
                 Internet
                     |
              :80 / :443 only
                     |
        +------------v-------------+
        |          nginx           |   TLS termination, HTTP -> HTTPS redirect,
        |  (only published ports)  |   routes / to WordPress and /phpmyadmin/ to phpMyAdmin
        +------+-------------+-----+
               |             |         internal Docker network (no published ports)
      +--------v----+  +-----v--------+
      |  WordPress  |  |  phpMyAdmin  |
      |  (php-fpm)  |  |              |
      +--------+----+  +-----+--------+
               |             |
            +--v-------------v--+
            |      MariaDB      |   named volume: database files
            +-------------------+
```

| Container  | Role                                   | Persistence                       |
|------------|----------------------------------------|-----------------------------------|
| nginx      | Reverse proxy, TLS, ACME challenge     | Reads certificates from the host  |
| wordpress  | php-fpm + WP-CLI, installs the site    | Named volume (site files, uploads)|
| phpmyadmin | Database administration UI             | None                              |
| mariadb    | Database                               | Named volume (database files)     |

Rules the stack follows: one process per container, services reach each other by name over the internal network, the database and php-fpm are never reachable from the internet, and containers have health checks so start-up order is enforced (`depends_on` with `service_healthy`).

## 3. AWS components

| Service | What it is used for |
|---------|---------------------|
| **EC2** | The virtual machine that runs the Docker stack. |
| **Elastic IP** | A static public IPv4 address that survives stop/start of the instance. The DNS record points at it. |
| **VPC, subnet and security group** | The VPC and subnet are the network the instance lives in. The security group is the cloud-level firewall: it allows inbound TCP 22, 80 and 443 and nothing else. |
| **IAM** | A dedicated IAM user (never the root account) whose access keys are used by Terraform. Grant it only the EC2 permissions Terraform needs (instance create/describe/terminate, address association, tags). |
| **Key pair** | The SSH key pair registered in the region. Key pairs are regional: a key created in one region does not exist in another. |

## 4. Design decision: Terraform provisions, Ansible configures

The subject only requires that the deployment script works from a bare Ubuntu 22.04 host with an SSH daemon and Python. Terraform is therefore an optional convenience layer in front of that contract, not part of it.

- **Terraform** creates the instance and attaches the Elastic IP. It looks up the network resources (VPC, subnet, security group, Elastic IP allocation) that must already exist; it does not create them.
- **Ansible** takes over as soon as the host answers over SSH. Everything after that point works on any Ubuntu 22.04 machine, wherever it came from.

Consequence: you can skip Terraform entirely and point the inventory at an existing server.

## 5. Prerequisites

### Control node

- Ansible (with a Python interpreter) and the collections used by the roles (`community.general`, `community.docker`).
- Terraform.
- AWS CLI, used to create and inspect the prerequisite resources below.
- A `.devcontainer` is provided to get a ready-made control node quickly.

### On AWS (once per region you deploy to)

Create these by hand beforehand and note their identifiers:

- Region to deploy in.
- VPC ID, subnet ID and security group ID (inbound 22, 80, 443).
- Elastic IP allocation ID.
- AMI ID for Ubuntu 22.04 LTS **in that region** (AMI IDs are regional).
- Key pair name and its private key.
- IAM user access key ID and secret access key.

### DNS

A DNS name pointing at the Elastic IP (a free DuckDNS subdomain works). It is needed for the Let's Encrypt certificate.

## 6. Secrets

Everything sensitive is encrypted with Ansible Vault:

- `inventory/host_vars/<instance>.yml`: one file per instance. Holds what is specific to that instance (AWS credentials, region and resource IDs, SSH private key).
- Group-level vars: application secrets shared by every instance (database passwords, WordPress admin credentials).

Rules:

- One vault password decrypts everything. It is never committed (`.vault-pass` is git-ignored).
- The SSH private key is written to `/tmp` with mode `0400` at the start of a run and deleted by the `cleanup` role at the end.
- `*.pem`, Terraform state and decrypted material are git-ignored.
- No secret appears in plain text in any role, template or Dockerfile.

Create or edit an encrypted file:

```bash
ansible-vault create  inventory/host_vars/<instance>.yml
ansible-vault edit    inventory/host_vars/<instance>.yml
```

## 7. How the playbook works

Entry point: `playbooks/site.yml`.

1. **Controller-side setup** (`local.yml`, runs on your machine): places the SSH key and runs Terraform to provision the instance.
2. **Wait for the target** to become reachable over SSH, then gather facts.
3. **Deploy** (`ec2.yml`, runs on every target host in parallel) through these roles, in order:

| Role | What it does |
|------|--------------|
| `ssh` | Writes the SSH private key from Vault to a temporary file. |
| `terraform` | Provisions the instance and Elastic IP association. |
| `infra` | Base system preparation and package installation (including certbot). |
| `ufw` | Host firewall: default deny inbound, allow 22/80/443. |
| `docker_install` | Installs Docker Engine and the Compose plugin. |
| `docker_verify` | Runs a test container to prove Docker works. |
| `compose` | Copies the build contexts, renders `docker-compose.yml` from a Jinja2 template, builds and starts the stack. |
| `ssl` | Obtains the Let's Encrypt certificate and switches nginx to HTTPS. |
| `smoke_test` | Checks that the site answers over HTTPS on the instance. |
| `cleanup` | Deletes the decrypted SSH key. |

The playbooks are idempotent: running them again converges to the same working state.

## 8. TLS with Let's Encrypt

Certificates come from Let's Encrypt through certbot, validated with the **ACME HTTP-01 challenge**: Let's Encrypt requests a token file at `http://<domain>/.well-known/acme-challenge/...` and issues the certificate only if the domain resolves to this server and the file is served.

This creates a chicken-and-egg problem: nginx must already be serving port 80 before a certificate exists, but the final nginx config needs the certificate. It is solved with two nginx configurations chosen at container start:

1. **Bootstrap**: no certificate found, so nginx listens on port 80 only, serves the ACME challenge directory and a health endpoint.
2. **Production**: certbot (on the host) obtains the certificate into `/etc/letsencrypt`, which is mounted read-only into the nginx container. nginx is restarted, finds the certificate, and loads the production config (HTTP redirects to HTTPS, TLS on 443).

The domain name is injected into the nginx config with `envsubst`, so there is a single source of truth. The certbot task is skipped when a certificate already exists, which avoids Let's Encrypt rate limits on re-runs.

## 9. Usage

From the repository root (`ansible.cfg` already points at the inventory and roles):

```bash
ansible-playbook playbooks/site.yml --ask-vault-pass
# or, with a password file kept outside git:
ansible-playbook playbooks/site.yml --vault-password-file .vault-pass
```

To deploy to an existing server and skip Terraform, run only the deployment part:

```bash
ansible-playbook playbooks/ec2.yml --ask-vault-pass
```

Teardown (instances and Elastic IPs can be billed while they exist):

```bash
terraform destroy   # from the Terraform directory, then release unused Elastic IPs
```

## 10. Deploying to several servers

Each server is one entry in `inventory/hosts` plus one encrypted file in `inventory/host_vars/`:

1. Add the host to `inventory/hosts`.
2. Create `inventory/host_vars/<host>.yml` with that host's region, resource IDs, key pair and credentials (vault-encrypted).
3. Run the playbook. The plays target `hosts: all`, so Ansible configures every host concurrently (5 forks by default, configurable with `-f`).

Different regions work the same way, since everything region-specific lives in that host's `host_vars`.

## 11. Verification

```bash
# Site and redirect
curl -I http://<domain>          # expect a redirect to https
curl -I https://<domain>         # expect 200/302 with a valid certificate

# Only 22, 80 and 443 are reachable from outside (run from another machine)
nmap -Pn -p- <elastic-ip>

# Persistence: reboot the instance, then confirm all containers are back
# and that posts, users and uploads are still there
ssh ubuntu@<elastic-ip> 'sudo reboot'
```

## 12. Security model

- **Cloud firewall:** the security group allows only 22, 80 and 443 inbound.
- **Host firewall:** UFW with default deny inbound. Note that Docker publishes ports through its own iptables rules, which bypass UFW, so the only ports published in the compose file are nginx's 80 and 443; the security group is the authoritative perimeter.
- **Network isolation:** MariaDB, php-fpm and phpMyAdmin publish no ports and are reachable only on the internal Docker network.
- **Secrets:** Vault-encrypted, no hard-coded credentials.
- **TLS:** valid Let's Encrypt certificate, HTTP redirected to HTTPS.

## 13. Known limitations

- **One domain, one server.** A DNS name points to a single IP, so only the instance the domain resolves to can obtain a certificate. On any additional instance the `ssl` role fails its challenge. This is expected; give each extra instance its own domain if it needs HTTPS.
- **Prerequisites are manual.** The VPC, subnet, security group and Elastic IP are not created by this code and must exist per region. Regional values (AMI, key pair) must be provided for each region.
- **Each instance needs its own Elastic IP** if it should keep a stable address.
- **phpMyAdmin is reachable through the public site** (`/phpmyadmin/`) behind its login page. Restrict it by IP or remove it for a real production deployment.
