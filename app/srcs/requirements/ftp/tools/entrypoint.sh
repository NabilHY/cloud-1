#!/bin/sh

set -e

if ! getent group "${FTP_USER}" >/dev/null; then
    addgroup -S "${FTP_USER}"
fi

if ! getent passwd "${FTP_USER}" >/dev/null; then
    adduser -D -G $FTP_USER $FTP_USER
    echo "$FTP_USER:$FTP_PASS" | chpasswd >/dev/null 2>&1
fi

mkdir -p /home/$FTP_USER
chown $FTP_USER:$FTP_USER /home/$FTP_USER
chmod 755 /home/$FTP_USER

exec "$@"