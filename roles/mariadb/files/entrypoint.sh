#!/bin/sh

echo "Starting MariaDB..."

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

get_secret "MYSQL_ROOT_PASSWORD" "wp_db_pass"
get_secret "WORDPRESS_DB_NAME" "db_name"
get_secret "WORDPRESS_DB_USER" "wp_admin_user"
get_secret "WORDPRESS_DB_PASSWORD" "wp_db_pass"


if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Db Init"
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db
    mariadbd --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE DATABASE IF NOT EXISTS \`$WORDPRESS_DB_NAME\`;
CREATE USER IF NOT EXISTS '$WORDPRESS_DB_USER'@'%' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';
GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO '$WORDPRESS_DB_USER'@'%';
FLUSH PRIVILEGES;
EOF
    echo "Database Initialized"
fi

echo "Starting $@"

exec "$@"