FROM alpine:3.22

RUN apk add --no-cache wget tar make build-base redis

COPY ./tools/entrypoint.sh ./entrypoint.sh

RUN chmod +x ./entrypoint.sh

EXPOSE 6379

ENTRYPOINT [ "./entrypoint.sh" ]
