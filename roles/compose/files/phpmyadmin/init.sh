#!/bin/sh

set -e

mkdir -p /run/lighttpd

cat >/var/www/localhost/htdocs/config.inc.php <<'EOF'
  <?php
  $cfg['blowfish_secret'] = 'a8F3kLmQ9xRvTuWyNpZcBdEjHsIoGn01';
  $i = 0;
  $i++;
  $cfg['Servers'][$i]['auth_type']       = 'cookie';
  $cfg['Servers'][$i]['host']            = getenv('PMA_HOST') ?: 'mariadb';
  $cfg['Servers'][$i]['port']            = getenv('PMA_PORT') ?: '3306';
  $cfg['Servers'][$i]['connect_type']    = 'tcp';
  $cfg['Servers'][$i]['compress']        = false;
  $cfg['Servers'][$i]['AllowNoPassword'] = false;
EOF

echo "lightpd server started !"

exec "$@"
