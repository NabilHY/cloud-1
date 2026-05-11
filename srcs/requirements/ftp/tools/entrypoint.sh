#!/bin/sh

set -e

addgroup $FTP_USER
adduser -D -G $FTP_USER $FTP_USER
echo "$FTP_USER:$FTP_PASS" | chpasswd >/dev/null 2>&1

mkdir -p /home/$FTP_USER
chown $FTP_USER:$FTP_USER /home/$FTP_USER
chmod 755 /home/$FTP_USER

exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
