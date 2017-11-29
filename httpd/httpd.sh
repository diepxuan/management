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

cat ~/public_html/code/httpd/httpd.conf > /etc/apache2/sites-available/ductn.conf

apt install -y libapache2-mod-php?.? php?.? php?.?-mysql php?.?-mbstring php?.?-mysqli php?.?-intl php?.?-curl php?.?-gd php?.?-mcrypt php?.?-soap php?.?-dom php?.?-xml php?.?-zip

a2ensite ductn.conf
a2dismod php?.?
a2enmod proxy proxy_http headers deflate expires rewrite mcrypt reqtimeout vhost_alias php7.0 ssl

service apache2 restart
service apache2 status
