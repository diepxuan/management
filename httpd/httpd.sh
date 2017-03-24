#!/usr/bin/env bash
cat httpd.conf > /etc/apache2/sites-available/ductn.conf

sudo apt install -y php*.*-mysql php*.*-mbstring php*.*-mysqli

a2ensite ductn.conf
a2dismod php5.5 php5.6 php7.1
a2enmod proxy proxy_http headers deflate expires rewrite vhost_alias php7.0

service apache2 restart
service apache2 status
