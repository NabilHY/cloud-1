#!/bin/sh

get_secret() {
    local var_name="$1"
    local secret_name="$2"
    local file_path="/run/secrets/$secret_name"

    if [ -f "$file_path" ]; then
        export "$var_name"=$(cat "$file_path")
        echo "LOG: Loaded $var_name from /run/secrets/$secret_name"
    else
        echo "FATAL: Missing secret file at $file_path"
        exit 1
    fi
}

get_secret "WORDPRESS_DB_NAME" "db_name"
get_secret "WORDPRESS_DB_USER" "wp_user_name"
get_secret "WORDPRESS_DB_PASSWORD" "wp_db_pass"
get_secret "WORDPRESS_DB_HOST" "db_host"
get_secret "WP_REDIS_PORT" "wp_redis_port"
get_secret "WP_DB_PORT" "db_port"
get_secret "WP_SITE_URL" "wp_site_url"
get_secret "WP_SITE_TITLE" "wp_site_title"
get_secret "WP_ADMIN_USER" "wp_admin_user"
get_secret "WP_ADMIN_PASSWORD" "wp_admin_pass"
get_secret "WP_ADMIN_EMAIL" "wp_admin_email"


chown -R nobody:nobody /var/www/html

cat > /var/www/html/wp-config.php << EOF
<?php
define( 'DB_NAME', '${WORDPRESS_DB_NAME}' );
define( 'DB_USER', '${WORDPRESS_DB_USER}' );
define( 'DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}' );
define( 'DB_HOST', '${WORDPRESS_DB_HOST}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

define( 'WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', '${WP_REDIS_PORT}');

\$table_prefix = 'wp_';

define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', true);

if ( ! defined( 'ABSPATH' ) )
	define( 'ABSPATH', __DIR__ . '/' );
require_once ABSPATH . 'wp-settings.php';
EOF

echo "Checking Redis connectivity"
until nc -z -w 2 redis ${WP_REDIS_PORT}; do
  echo "Redis is not ready - sleeping ... "
  sleep 0.5
done

echo "Redis is up"

echo "Checking MariaDB connectivity"
until nc -z -w 2 ${WORDPRESS_DB_HOST} ${WP_DB_PORT}; do
  echo "Redis is not ready - sleeping ... "
  sleep 0.5
done

echo "MariaDB is up"

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar >/dev/null 2>&1

chmod +x wp-cli.phar 

mv wp-cli.phar /usr/local/bin/wp

wp --info

# # Redis PHP Extension

wp core install \
  --url="${WP_SITE_URL}" \
  --title="${WP_SITE_TITLE}" \
  --admin_user="${WP_ADMIN_USER}" \
  --admin_password="${WP_ADMIN_PASSWORD}" \
  --admin_email="${WP_ADMIN_EMAIL}" \
  --skip-email \
  --path=/var/www/html \
  --allow-root

wp plugin install redis-cache --activate --allow-root

wp plugin activate redis-cache --allow-root

wp redis enable --allow-root

wp  theme activate twentytwentyfour  --allow-root

exec "$@"