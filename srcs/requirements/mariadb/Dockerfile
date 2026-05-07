FROM alpine:3.22

RUN apk update && apk add mariadb mariadb-client

RUN mkdir -p /run/mysqld /var/lib/mysql

RUN chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY ./tools/entrypoint.sh /entrypoint.sh

COPY ./tools/custom.cnf /etc/my.cnf.d/mariadb-server.cnf

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]