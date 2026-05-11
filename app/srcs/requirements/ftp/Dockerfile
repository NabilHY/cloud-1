FROM alpine:3.22

RUN apk update && apk add --no-cache vsftpd

EXPOSE 21 21000-21010

COPY ftp.conf /etc/vsftpd/vsftpd.conf

COPY tools/entrypoint.sh /tools/entrypoint.sh

RUN chmod +x /tools/entrypoint.sh

ENTRYPOINT ["/tools/entrypoint.sh"]