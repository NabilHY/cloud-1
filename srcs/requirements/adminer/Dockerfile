FROM alpine:3.22

RUN apk update && apk add --no-cache php php-mysqli php-session curl

RUN mkdir -p /var/www/adminer

RUN curl -L -o /var/www/adminer/index.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

RUN cat /var/www/adminer/index.php

WORKDIR /var/www/adminer

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]