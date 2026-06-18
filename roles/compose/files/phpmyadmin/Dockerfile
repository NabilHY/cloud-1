FROM alpine:3.22

ARG CACHE_BUST=1.6

RUN apk update && apk add --no-cache \
  php \
  lighttpd \
  php-cgi	\
  php-session	\
  php-mbstring	\
  php-iconv	\
  php-mysqli	\
  php-json	\
  tini	\
  curl \
  wget  && \
  rm -rf /var/cache/apk/*

# Download phpMyAdmin
RUN wget -qO- https://files.phpmyadmin.net/phpMyAdmin/5.2.2/phpMyAdmin-5.2.2-all-languages.tar.gz \
  | tar xz --strip-components=1 -C /var/www/localhost/htdocs/

RUN mkdir -p /run/lighttpd

RUN chown -R lighttpd:lighttpd /run/lighttpd

# Enable fastcgi module
RUN echo 'include "/etc/lighttpd/mod_fastcgi.conf"' >> /etc/lighttpd/lighttpd.conf

COPY init.sh /tmp/init.sh
RUN chmod +x /tmp/init.sh

ENTRYPOINT ["/sbin/tini", "--", "/tmp/init.sh"]
CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
