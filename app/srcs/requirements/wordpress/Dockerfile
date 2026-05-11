FROM debian:bullseye

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    curl \
    sudo \
    ghostscript \
    php \
    php-fpm \
    php-bcmath \
    php-curl \
    php-imagick \
    php-intl \
    php-json \
    php-mbstring \
    php-mysql \
    php-xml \
    php-zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY tools/entrypoint.sh tools/entrypoint.sh

RUN chmod +x tools/entrypoint.sh

RUN mkdir -p /var/www/html

RUN chmod -R 777 /var/www/html

RUN curl -s https://wordpress.org/latest.tar.gz | tar -xz --strip-components=1 -C /var/www/html && \
    chown -R nobody:nogroup /var/www/html && \
    chmod -R 755 /var/www/html

# Use dynamic PHP version path
RUN PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;') && \
    CONF_FILE="/etc/php/$PHP_VERSION/fpm/pool.d/www.conf" && \
    sed -i 's|^user = .*|user = nobody|' "$CONF_FILE" && \
    sed -i 's|^group = .*|group = nogroup|' "$CONF_FILE" && \
    sed -i 's|^listen = .*|listen = 9000|' "$CONF_FILE" && \
    sed -i 's|^;*clear_env = .*|clear_env = no|' "$CONF_FILE"

RUN mkdir -p /run/php && chown -R nobody:nogroup /run/php

RUN ln -s /usr/sbin/php-fpm7.4 /usr/sbin/php-fpm

WORKDIR /var/www/html

ENTRYPOINT [ "/tools/entrypoint.sh" ]
CMD ["php-fpm7.4", "-F"]



