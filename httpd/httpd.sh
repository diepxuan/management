#!/usr/bin/env bash
cat httpd.conf > /etc/apache2/sites-available/ductn.conf

a2ensite ductn.conf
a2enmod proxy proxy_http headers deflate

service apache2 restart
