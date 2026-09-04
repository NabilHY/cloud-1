#!/bin/sh

chown -R nobody:nobody /var/www/html

cat >/var/www/html/wp-config.php <<EOF
<?php
define( 'DB_NAME', '${WORDPRESS_DB_NAME}' );
define( 'DB_USER', '${WORDPRESS_DB_USER}' );
define( 'DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}' );
define( 'DB_HOST', '${WORDPRESS_DB_HOST}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

\$table_prefix = 'wp_';

if ( ! defined( 'ABSPATH' ) )
	define( 'ABSPATH', __DIR__ . '/' );
require_once ABSPATH . 'wp-settings.php';
EOF

echo "Checking MariaDB connectivity"
until nc -z -w 2 ${WORDPRESS_DB_HOST} ${WP_DB_PORT}; do
  echo "MariaDB is not ready - sleeping ... "
  sleep 0.5
done

echo "MariaDB is up"

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar >/dev/null 2>&1

chmod +x wp-cli.phar

mv wp-cli.phar /usr/local/bin/wp

wp --info

wp core install \
  --url="${WP_SITE_URL}" \
  --title="${WP_SITE_TITLE}" \
  --admin_user="${WP_ADMIN_USER}" \
  --admin_password="${WP_ADMIN_PASSWORD}" \
  --admin_email="${WP_ADMIN_EMAIL}" \
  --skip-email \
  --path=/var/www/html \
  --allow-root

wp theme activate twentytwentyfour --allow-root

exec "$@"
