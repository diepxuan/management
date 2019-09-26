#!/bin/bash


#########################################
# PHP Install
#########################################
# ssh hasingdon -tt "
# sudo add-apt-repository ppa:ondrej/php
# sudo apt update
# sudo apt install libapache2-mod-php?.? -y
# sudo update-alternatives --config php
# "

#########################################
# Apache Install
#########################################
# ssh hasingdon -tt "
# sudo apt-get update
# sudo apt-get install apache2
# sudo apache2ctl configtest

# apt install -y libapache2-mod-php7.0 php7.0 php7.0-mysql php7.0-mbstring php7.0-mysqli php7.0-intl php7.0-curl php7.0-gd php7.0-mcrypt php7.0-soap php7.0-dom php7.0-xml php7.0-zip

# sudo systemctl restart apache2
# "

echo ""
echo "# ssl"
echo "#########################################"
ssh -t hasingdon mkdir -p /tmp/ssl/
ssh -t hasingdon mkdir -p /home/hasingdon.com/.ssl/
scp /var/www/base/httpd/hasingdon.com/ca_bundle.crt 	hasingdon:/tmp/ssl/ &>/dev/null
scp /var/www/base/httpd/hasingdon.com/certificate.crt  	hasingdon:/tmp/ssl/ &>/dev/null
scp /var/www/base/httpd/hasingdon.com/private.key  		hasingdon:/tmp/ssl/ &>/dev/null
ssh -tt hasingdon sudo mv -Z /tmp/ssl /home/hasingdon.com/.ssl
ssh -tt hasingdon sudo chown -R hasingdon.com:www-data /home/hasingdon.com/.ssl

echo ""
echo "# httpd config"
echo "#########################################"
scp /var/www/base/httpd/hasingdon.com/hasingdon.com.conf hasingdon:/tmp/ &>/dev/null
ssh -tt hasingdon sudo mv -Z /tmp/hasingdon.com.conf /etc/apache2/sites-available/hasingdon.com.conf

ssh -t hasingdon sudo a2ensite hasingdon.com.conf
ssh -t hasingdon sudo a2dismod php5.5 php5.6 php7.1 php7.2
ssh -t hasingdon sudo a2enmod proxy proxy_http headers deflate expires rewrite mcrypt reqtimeout vhost_alias php7.0 ssl
ssh -t hasingdon sudo service apache2 restart
ssh -t hasingdon sudo service apache2 status
