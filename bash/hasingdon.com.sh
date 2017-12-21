#!/usr/bin/env bash

#########################################
# Apache Install
#########################################
# sudo apt-get update
# sudo apt-get install apache2
# sudo apache2ctl configtest
# sudo systemctl restart apache2

#########################################
# PHP Install
#########################################
# sudo add-apt-repository ppa:ondrej/php
# sudo apt update
# sudo apt install libapache2-mod-php?.? -y
# sudo update-alternatives --config php

#########################################
rm -rf /etc/apache2/sites-available/gss.conf
cat ~/public_html/code/httpd/hasingdon.com.conf > /etc/apache2/sites-available/hasingdon.com.conf

#########################################
cat ~/public_html/code/httpd/hasingdon.com/ca_bundle.crt > /home/hasingdon.com/.ssl/ca_bundle.crt
cat ~/public_html/code/httpd/hasingdon.com/certificate.crt > /home/hasingdon.com/.ssl/certificate.crt
cat ~/public_html/code/httpd/hasingdon.com/private.key > /home/hasingdon.com/.ssl/private.key
chown -R hasingdon.com:www-data /home/hasingdon.com/.ssl

#########################################
cat ~/public_html/code/httpd/hasingdon.com/hasingdon.com.conf.sample > /home/hasingdon.com/httpd.conf
chown -R hasingdon.com:www-data /home/hasingdon.com/httpd.conf

#########################################
apt install -y libapache2-mod-php7.0 php7.0 php7.0-mysql php7.0-mbstring php7.0-mysqli php7.0-intl php7.0-curl php7.0-gd php7.0-mcrypt php7.0-soap php7.0-dom php7.0-xml php7.0-zip

a2ensite hasingdon.com.conf
a2dismod php5.5 php5.6 php7.1 php7.2
a2enmod proxy proxy_http headers deflate expires rewrite mcrypt reqtimeout vhost_alias php7.0 ssl

service apache2 restart
service apache2 status
