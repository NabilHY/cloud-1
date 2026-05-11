FROM alpine:3.22

RUN apk add --no-cache python3

WORKDIR /static-site

COPY /index.html /static-site

COPY /styles.css /static-site

RUN chmod -R 755 /static-site/index.html

RUN chmod -R 755 /static-site/styles.css

CMD ["python3", "-m", "http.server", "8081"]