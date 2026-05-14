FROM alpine:3.22

ARG CACHE_BUST=1.1

RUN apk update && \
    apk add mariadb mariadb-client tini && \
    mkdir -p /run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql && \
    rm -rf /var/cache/apk/*

COPY ./tools/custom.cnf /etc/my.cnf.d/mariadb-server.cnf

COPY ./tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# pid-1 to be managed by tini init wrapper
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

CMD ["mariadbd", "--user=mysql", "--console"]