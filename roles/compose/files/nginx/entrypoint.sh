#!/bin/sh

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
  echo "🔐 Generating SSL certificate for $DOMAIN_NAME..."
  openssl req -x509 -nodes -days 365 \
    -subj "/C=MA/ST=Casablanca/L=Casa/O=cloud1/CN=$DOMAIN_NAME" \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt >/dev/null 2>&1
fi

echo "SSL certificate generated !"

exec "$@"
