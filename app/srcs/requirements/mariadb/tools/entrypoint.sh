#!/bin/sh
set -e

echo "Starting MariaDB..."
# mariadbd-safe --socket=/run/mysqld/mysqld.sock &

# Wait longer for MariaDB to initialize
sleep 5

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db
    mariadbd --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE DATABASE IF NOT EXISTS \`$WORDPRESS_DB_NAME\`;
CREATE USER IF NOT EXISTS '$WORDPRESS_DB_USER'@'%' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';
GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO '$WORDPRESS_DB_USER'@'%';
FLUSH PRIVILEGES;
EOF
fi

echo "DB Injected successfully"

exec mariadbd --user=mysql