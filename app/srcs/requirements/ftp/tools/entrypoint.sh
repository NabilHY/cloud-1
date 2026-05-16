#!/bin/sh

get_secret() {
    local var_name="$1"
    local secret_name="$2"
    local file_path="/run/secrets/$2"

    if [ -f "$file_path" ]; then
        export "$var_name"=$(cat "$file_path")
    else
        exit 1
    fi
}

get_secret "FTP_USER" "ftp_user"

get_secret "FTP_PASS" "ftp_pass"

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