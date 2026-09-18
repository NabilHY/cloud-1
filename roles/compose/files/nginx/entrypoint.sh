#!/bin/sh

CERT_DIR="/etc/letsencrypt/live/${DOMAIN_NAME}"

if [ -s "${CERT_DIR}/fullchain.pem" ] && [ -s "${CERT_DIR}/privkey.pem" ]; then
  envsubst '${DOMAIN_NAME}' </etc/nginx/nginx.production.conf >/etc/nginx/nginx.conf
else
  envsubst '${DOMAIN_NAME}' </etc/nginx/nginx.bootstrap.conf >/etc/nginx/nginx.conf
fi

nginx -t

exec "$@"

