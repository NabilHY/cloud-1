FROM alpine:3.22

ENV PORTAINER_VERSION=2.20.2
ENV DEBIAN_FRONTEND=noninteractive

RUN apk add --no-cache \
    ca-certificates \
    curl \
    dumb-init

RUN mkdir -p /data /opt/portainer

WORKDIR /opt/portainer

RUN curl -L https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-${PORTAINER_VERSION}-linux-amd64.tar.gz \
    | tar -xz --strip-components=1 && \
    chmod +x portainer

EXPOSE 9443

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["./portainer", "--data", "/data"]