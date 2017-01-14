#!/usr/bin/env bash
cat httpd.conf > /etc/apache2/sites-available/ductn.conf

a2ensite ductn.conf
a2enmod proxy proxy_http headers deflate expires rewrite

service apache2 restart
service apache2 status
