#!/usr/bin/env bash

# sudo apt update
# sudo apt install vsftpd -y

cat ~/public_html/code/vsftpd/vsftpd.conf > /etc/vsftpd.conf

cp -arf ~/public_html/code/vsftpd/* > /etc/

service vsftpd restart
service vsftpd status
