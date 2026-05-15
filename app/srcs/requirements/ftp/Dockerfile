FROM alpine:3.22

ARG CACHE_BUST=1

RUN apk update && apk add --no-cache vsftpd curl tini netcat-openbsd && rm -rf /var/cache/apk/*

EXPOSE 21 21000-21010

# in FTP communication is split into wo parts:
        # port 21 control : this is where you send username password and commands
        # port 21000 - 21010 (passive data) these are the ports used for the actual
        # file transfers bacause a container needs to move data ot needs a range of ports
        # available so multiple files can be moved at once 

COPY ftp.conf /etc/vsftpd/vsftpd.conf

COPY tools/entrypoint.sh /tools/entrypoint.sh

RUN chmod +x /tools/entrypoint.sh

ENTRYPOINT ["/sbin/tini", "--", "/tools/entrypoint.sh"]

CMD ["vsftpd", "/etc/vsftpd/vsftpd.conf"]

