FROM alpine:3.22

RUN apk update && apk add --no-cache openssl curl ca-certificates bash netcat-openbsd

COPY tools/entrypoint.sh /tools/entrypoint.sh

RUN chmod +x /tools/entrypoint.sh

COPY nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT [ "/tools/entrypoint.sh" ]