FROM alpine:3.22

ARG CACHE_BUST=1.1

RUN apk update && \
    apk add --no-cache php php-mysqli php-session curl tini && \
    mkdir -p /var/www/adminer && \
    curl -L -o /var/www/adminer/index.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php && \
    cat /var/www/adminer/index.php && \
    rm -rf /var/cache/apk/*

WORKDIR /var/www/adminer

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]