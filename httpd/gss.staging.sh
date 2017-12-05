#!/usr/bin/env bash

#########################################
# copy config file
#########################################
cat ~/public_html/code/httpd/gss.staging.conf | ssh gsmartsolutions.staging "sudo tee /etc/apache2/sites-available/gss.conf"

#########################################
# Apache Install
#########################################
sudo apt-get update
sudo apt-get install apache2
sudo apache2ctl configtest
sudo systemctl restart apache2

#########################################
# PHP Install
#########################################
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install libapache2-mod-php?.? -y
sudo update-alternatives --config php

#########################################
apt install -y libapache2-mod-php7.0 php7.0 php7.0-mysql php7.0-mbstring php7.0-mysqli php7.0-intl php7.0-curl php7.0-gd php7.0-mcrypt php7.0-soap php7.0-dom php7.0-xml php7.0-zip

sudo a2ensite gss.conf
sudo a2dismod php5.5 php5.6 php7.1 php7.2
sudo a2enmod proxy proxy_http headers deflate expires rewrite mcrypt reqtimeout vhost_alias php7.0 ssl

sudo service apache2 restart
sudo service apache2 status
