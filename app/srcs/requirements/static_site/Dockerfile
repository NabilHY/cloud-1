FROM alpine:3.22

RUN apk add --no-cache python3 tini wget && \
    rm -rf /var/cache/apk/*

WORKDIR /static-site

COPY /index.html /static-site

COPY /styles.css /static-site

RUN chmod -R 755 /static-site/index.html && \
    chmod -R 755 /static-site/styles.css

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["python3", "-m", "http.server", "8081"]