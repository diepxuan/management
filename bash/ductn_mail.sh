#!/bin/bash

mkdir -p /tmp/ssl/
ssh -t mail.diepxuan.com mkdir -p /tmp/ssl/

ssh slave.diepxuan.com sudo cat /etc/letsencrypt/live/diepxuan.com/fullchain.pem | tee /tmp/ssl/ssl_certificate.pem &>/dev/null
ssh slave.diepxuan.com sudo cat /etc/letsencrypt/live/diepxuan.com/privkey.pem | tee /tmp/ssl/ssl_private_key.pem &>/dev/null

scp /tmp/ssl/ssl_certificate.pem mail.diepxuan.com:/tmp/ssl/ssl_certificate.pem &>/dev/null
scp /tmp/ssl/ssl_private_key.pem mail.diepxuan.com:/tmp/ssl/ssl_private_key.pem &>/dev/null

ssh -t mail.diepxuan.com "cat /tmp/ssl/ssl_certificate.pem | sudo tee /home/user-data/ssl/ssl_certificate.pem" &>/dev/null
ssh -t mail.diepxuan.com "cat /tmp/ssl/ssl_private_key.pem | sudo tee /home/user-data/ssl/ssl_private_key.pem" &>/dev/null
ssh -t mail.diepxuan.com "sudo service nginx restart"
