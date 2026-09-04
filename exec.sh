#!/bin/bash

set -eou pipefail

readonly C2_IP="52.86.240.233"
readonly MAX_RETRIES=30
readonly RETRY_INTERVAL=10

echo "### Running Terraform Automation - Creating cloud infra ###"
echo "=======================================
AWS Instance Specifications
=======================================
Name Tag:          cloud-1
Region:            us-east-1
Instance Type:     t3.micro
AMI ID:            ami-0b6d9d3d33ba97d99
Key Pair:          cloud-1
VPC ID:            vpc-0f383d92a34d3fa17
Subnet ID:         subnet-03d84bdc3c69c23b1
Security Group ID: sg-039b04d34a24ef144
Elastic IP Alloc:  eipalloc-0b6b6ff268e0c25d1
======================================="
echo "\n"
terraform init
terraform apply

readonly INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=ip-address,Values=52.86.240.233" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text)

echo "## Wainting for AWS-level readiness ##"
aws ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID"

echo "AWS EC2 Current Status ..."
aws ec2 describe-instance-status \
  --instance-ids "$INSTANCE_ID" \
  --query 'InstanceStatuses[*].[InstanceId, InstanceState.Name,
SystemStatus.Status, InstanceStatus.Status]' \
  --output table

echo "===> Running Ansible Provissionning"
ansible-playbook playbooks/site.yml

echo "===> Workflow Completed : visit: https://nhayoun.duckdns.org/"
