FROM alpine:3.22

RUN apk update && \
    apk add --no-cache \
    openssl \
    curl \
    ca-certificates \
    bash \
    netcat-openbsd \
    tini \
    nginx && \
    mkdir -p /etc/nginx/ssl /run/nginx /var/www/html && \
    rm -rf /var/cache/apk/*

# running apk add downloads index files available packages and the .apk packages themselves , by default theyre
# stored in /var/cache/apk so it doesnt have to download them agian later
# cahce is dead weight ince software is installed it shall be removed
# why the no cache : it downloads the package installs it and then deletes the package file automatically 
# what it misses sometimes leaves behind the updated package index 

# why tini even tho nginx is self sufficient : running a shell script as an entrpoint shell is pid 1 and shell wont 
# fordward singlas

COPY nginx.conf /etc/nginx/nginx.conf

COPY entrypoint.sh /opt/compose/nginx/entrypoint.sh

RUN chmod +x /opt/compose/nginx/entrypoint.sh && \ 
    mkdir -p /etc/nginx/ssl

ENTRYPOINT [ "/sbin/tini", "--", "/opt/compose/nginx/entrypoint.sh" ]

CMD ["nginx", "-g", "daemon off;"]
