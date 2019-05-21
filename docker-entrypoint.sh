#!/bin/sh

if [ ! -f /etc/vsftpd/vsftpd.pem ]; then
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/vsftpd/vsftpd.pem -out /etc/vsftpd/vsftpd.pem -subj "/C=RU/O=vsftpd/CN=example.org"
fi

cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.custom.conf

sed -i "s/anonymous_enable=YES/anonymous_enable=NO/" /etc/vsftpd/vsftpd.custom.conf

cat <<EOF >> /etc/vsftpd/vsftpd.custom.conf
ssl_enable=YES
rsa_cert_file=/etc/vsftpd/vsftpd.pem
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
ssl_ciphers=HIGH
force_local_data_ssl=YES
force_local_logins_ssl=YES
allow_anon_ssl=NO
require_ssl_reuse=NO
seccomp_sandbox=NO
local_enable=YES
write_enable=YES
local_umask=022
pasv_enable=YES
pasv_max_port=20000
pasv_min_port=20000
log_ftp_protocol=YES
vsftpd_log_file=/var/log/vsftpd.log
xferlog_enable=YES
xferlog_std_format=YES
EOF

if [ -z ${PASSWORD} ]; then
  PASSWORD=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-8};echo;)
  echo "Generated password for user 'files': ${PASSWORD}"
fi

echo "files:${PASSWORD}" |/usr/sbin/chpasswd
chown files:files /home/files/ -R

if [ -z $1 ]; then
  /usr/sbin/vsftpd /etc/vsftpd/vsftpd.custom.conf
else
  $@
fi
