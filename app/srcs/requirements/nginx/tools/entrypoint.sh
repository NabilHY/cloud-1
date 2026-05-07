#!/bin/sh
set -e

# Install a reliable netcat version if needed
apk add --no-cache netcat-openbsd

printf "%s%s%s%s\n" \
"@nginx " \
"http://nginx.org/packages/alpine/v" \
`egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release` \
"/main" \
| tee -a /etc/apk/repositories >/dev/null 2>&1

curl -o /etc/apk/keys/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub >/dev/null 2>&1

mkdir -p /etc/nginx/ssl >/dev/null 2>&1

openssl req -x509 -nodes -days 365 \
  -subj "/C=MA/ST=Casablanca/L=Casa/O=Inception/CN=$DOMAIN_NAME" \
  -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key \
  -out /etc/nginx/ssl/nginx.crt >/dev/null 2>&1

openssl rsa -pubin -in /etc/apk/keys/nginx_signing.rsa.pub -text -noout >/dev/null 2>&1

apk add nginx@nginx >/dev/null 2>&1

# Wait for WordPress FPM to become available
echo "⏳ Waiting for wordpress:9000 to become reachable..."
until nc -z -w5 wordpress 9000; do
    echo "Still waiting for WordPress..."
    sleep 1
done

echo "✅ WordPress is up — starting NGINX..."
exec nginx -g 'daemon off;'