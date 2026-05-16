#!/bin/sh

mkdir -p /etc/nginx/ssl

get_secret() {
    local var_name="$1"
    local secret_name="$2"
    local file_path="/run/secrets/$secret_name"

    if [ -f "$file_path" ]; then
        export var_name=$(cat "$file_path")
    else
        exit 1
    fi
}

get_secret "DOMAIN_NAME" "domain_name"

if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    echo "🔐 Generating SSL certificate for $DOMAIN_NAME..."
    openssl req -x509 -nodes -days 365 \
      -subj "/C=MA/ST=Casablanca/L=Casa/O=Inception/CN=$DOMAIN_NAME" \
      -newkey rsa:2048 \
      -keyout /etc/nginx/ssl/nginx.key \
      -out /etc/nginx/ssl/nginx.crt > /dev/null 2>&1
fi

# Wait for WordPress FPM to become available
echo "⏳ Waiting for wordpress:9000 to become reachable..."
until nc -z -w5 wordpress 9000; do
    echo "Still waiting for WordPress..."
    sleep 1
done

echo "✅ WordPress is up — starting NGINX..."
exec "$@" 