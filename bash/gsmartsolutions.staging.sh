#!/bin/bash

#########################################
#
# Clean
#
#########################################
ssh gsmartsolutions.staging "
# Clean
sudo rm -rf /var/log/*.gz

# auth
cat /dev/null | sudo tee /var/log/auth.log
sudo chown syslog:adm /var/log/auth.log
sudo chmod 640 /var/log/auth.log

# kern
cat /dev/null | sudo tee /var/log/kern.log
sudo chown syslog:adm /var/log/kern.log
sudo chmod 640 /var/log/kern.log

# syslog
cat /dev/null | sudo tee /var/log/syslog
sudo chown syslog:adm /var/log/syslog
sudo chmod 640 /var/log/syslog

# mysql
sudo mkdir -p /var/log/mysql
sudo chown mysql:adm /var/log/mysql
sudo chmod 2750 /var/log/mysql

# apache2
sudo mkdir -p /var/log/apache2
sudo chown root:adm /var/log/apache2
sudo chmod 750 /var/log/apache2
"

####################################
#
# completion
#
####################################
# ~/public_html/code/bash/completion/magerun.setup
# ~/public_html/code/bash/completion/magerun2.setup
cat ~/public_html/code/bash/.bash_aliases | ssh gsmartsolutions.staging "cat > ~/.bash_aliases"
ssh gsmartsolutions.staging "mkdir -p ~/.completion"
scp -r ~/public_html/code/bash/completion/*.sh gsmartsolutions.staging:~/.completion/
ssh gsmartsolutions.staging "chmod 775 ~/.completion"

####################################
#
# SSH
#
####################################
# Create PEM file
# ##############################
#
# openssl rsa -in id_rsa -outform PEM -out id_rsa.pem

# Change passphrase
# ##############################
# SYNOPSIS
# #ssh-keygen [-q] [-b bits] -t type [-N new_passphrase] [-C comment] [-f output_keyfile]
# #ssh-keygen -p [-P old_passphrase] [-N new_passphrase] [-f keyfile]
# #-f filename Specifies the filename of the key file.
# -N new_passphrase     Provides the new passphrase.
# -P passphrase         Provides the (old) passphrase.
# -p                    Requests changing the passphrase of a private key file instead of
#                       creating a new private key.  The program will prompt for the file
#                       containing the private key, for the old passphrase, and twice for
#                       the new passphrase.
#
# ssh-keygen -f id_rsa -p

# Setup
# ##############################
ssh gsmartsolutions.staging "
mkdir -p ~/.ssh
chmod 700 ~/.ssh
"
# cat ~/public_html/code/ssh/gss.pub | ssh gsmartsolutions.staging "cat >> ~/.ssh/authorized_keys"
# cat ~/public_html/code/ssh/tci.pub | ssh gsmartsolutions.staging "cat >> ~/.ssh/authorized_keys"

# ssh private key
cat ~/public_html/code/ssh/tci | ssh gsmartsolutions.staging "cat > ~/.ssh/id_rsa"
ssh gsmartsolutions.staging "chmod 600 ~/.ssh/*"

#########################################
#
# Apache Install
#
#########################################
# sudo apt update
# sudo apt install apache2 -y
# sudo apache2ctl configtest
# sudo service apache2 restart

#########################################
#
# nginx Install
#
#########################################
# sudo apt update
# sudo apt install nginx -y
# sudo nginx -t
# sudo service nginx restart

#########################################
#
# PHP Install
#
#########################################
# sudo add-apt-repository ppa:ondrej/php
# sudo apt update
# sudo apt install libapache2-mod-php?.? php?.?-fpm -y
# sudo update-alternatives --config php

#########################################
#
# copy config file
#
#########################################
ssh gsmartsolutions.staging "mkdir -p ~/.ssl"
scp ~/public_html/code/httpd/twentyci.asia/private.key gsmartsolutions.staging:~/.ssl/
scp ~/public_html/code/httpd/twentyci.asia/certificate.crt gsmartsolutions.staging:~/.ssl/
ssh gsmartsolutions.staging "echo '' >> ~/.ssl/certificate.crt"
cat ~/public_html/code/httpd/twentyci.asia/ca_bundle.crt | ssh gsmartsolutions.staging "tee -a ~/.ssl/certificate.crt"
ssh gsmartsolutions.staging "echo '' >> ~/.ssl/certificate.crt"

#########################################
# Apache
#########################################
# cat ~/public_html/code/httpd/twentyci.asia/apache2.conf | ssh gsmartsolutions.staging "sudo tee /etc/apache2/sites-available/gss.conf"
# sudo systemctl enable apache2
# sudo systemctl disable nginx
#########################################
# ssh gsmartsolutions.staging "
# sudo apt install -y libapache2-mod-php?.? php?.? php?.?-mysql php?.?-mbstring php?.?-mysqli php?.?-intl php?.?-curl php?.?-gd php?.?-mcrypt php?.?-soap php?.?-dom php?.?-xml php?.?-zip

# sudo a2ensite gss.conf
# sudo a2dismod php?.?
# sudo a2enmod proxy proxy_http headers deflate expires rewrite mcrypt reqtimeout vhost_alias php7.0 ssl

# sudo service apache2 restart
# sudo service apache2 status
# "

#########################################
# Nginx
#########################################
cat ~/public_html/code/httpd/twentyci.asia/nginx.conf | ssh gsmartsolutions.staging "sudo tee /etc/nginx/sites-available/twentyci.asia"
ssh gsmartsolutions.staging "sudo ln -sfn /etc/nginx/sites-available/twentyci.asia /etc/nginx/sites-enabled/twentyci.asia"
sudo systemctl disable apache2
sudo systemctl enable nginx
#########################################
ssh gsmartsolutions.staging "
sudo ln -sfn /etc/nginx/sites-available/twentyci.asia /etc/nginx/sites-enabled/twentyci.asia

sudo service nginx restart
sudo nginx -t
"

#########################################
#
# Firewall
#
#########################################
ssh gsmartsolutions.staging "
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow mysql
sudo ufw allow 8983/tcp
"
