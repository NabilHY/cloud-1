#!/bin/bash

set -e

chown -R www-data:www-data /var/www/html

cat > /var/www/html/wp-config.php << EOF
<?php
define( 'DB_NAME', '${WORDPRESS_DB_NAME}' );
define( 'DB_USER', '${WORDPRESS_DB_USER}' );
define( 'DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}' );
define( 'DB_HOST', '${WORDPRESS_DB_HOST}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

define( 'WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', 6379);

\$table_prefix = 'wp_';

define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', true);

if ( ! defined( 'ABSPATH' ) )
	define( 'ABSPATH', __DIR__ . '/' );
require_once ABSPATH . 'wp-settings.php';
EOF

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar >/dev/null 2>&1

chmod +x wp-cli.phar 

mv wp-cli.phar /usr/local/bin/wp

wp --info


# Redis PHP Extension

RUN apt-get update && apt-get install -y php-redis && \
    apt clean && rm -rf /var/lib/apt/lists/*

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

wp redis enable --allow-root

wp  theme activate twentytwentyfour  --allow-root

exec "$@"