FROM alpine:3.22

ARG CACHE_BUST=1.6

RUN apk update && apk add --no-cache \
    curl \
    sudo \
    ghostscript \
    php83 \
    tini \
    php83-fpm \
    php83-bcmath \
    php83-curl \
    php83-pecl-imagick \
    php83-intl \
    php83-mbstring \
    php83-mysqli \
    php83-mysqlnd \
    php83-xml \
    php83-zip \
    php83-phar \
    mariadb-client \
    #php-redis 
    && \
    CONF_FILE="/etc/php83/php-fpm.d/www.conf" && \
    sed -i 's|^user = .*|user = nobody|' "$CONF_FILE" && \
    sed -i 's|^group = .*|group = nobody|' "$CONF_FILE" && \
    sed -i 's|^listen = .*|listen = 9000|' "$CONF_FILE" && \
    sed -i 's|^;*clear_env = .*|clear_env = no|' "$CONF_FILE" && \
    mkdir -p /var/www/html && \
    curl -s https://wordpress.org/latest.tar.gz | tar -xz --strip-components=1 -C /var/www/html && \
    chown -R nobody:nobody /var/www/html && \
    ln -s /usr/sbin/php-fpm83 /usr/sbin/php-fpm && \
    rm -rf /var/cache/apk/* 

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html

ENTRYPOINT [ "/sbin/tini", "--", "/usr/local/bin/entrypoint.sh" ]

CMD ["php-fpm", "-F"]
