#!/bin/bash

#########################################
#
# Clean
#
#########################################
ssh local.tci "
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
# /var/www/base/bash/completion/magerun.setup
# /var/www/base/bash/completion/magerun2.setup
cat /var/www/base/bash/.bash_aliases | ssh local.tci "cat > ~/.bash_aliases"
ssh local.tci "mkdir -p ~/.completion"
scp -r /var/www/base/bash/completion/*.sh local.tci:~/.completion/
ssh local.tci "chmod 775 ~/.completion"

####################################
#
# git
#
####################################
# cat /var/www/base/bash/git/.gitignore | ssh local.tci "cat > ~/.gitignore"
ssh local.tci "
git config --global core.excludesfile ~/.gitignore

# setting
git config --global user.name \"Trần Ngọc Đức\"
git config --global user.email \"caothu91@gmail.com\"

# push
git config --global push.default simple

# file mode
git config --global core.fileMode false

# line endings
git config --global core.autocrlf false
git config --global core.eol lf

# Cleanup
git config --global gc.auto 0
"

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
ssh local.tci "
mkdir -p ~/.ssh
chmod 700 ~/.ssh
"
# cat /var/www/base/ssh/gss.pub | ssh local.tci "cat >> ~/.ssh/authorized_keys"

# ssh private key
cat /var/www/base/ssh/gss | ssh local.tci "cat > ~/.ssh/id_rsa"
ssh local.tci "chmod 600 ~/.ssh/*"

# echo  "
# Host tci.staging
#     HostName 128.199.118.164
#     User gssadmin
# " | ssh local.tci "cat >> ~/.ssh/config"

#########################################
#
# Apache Install
#
#########################################
# sudo apt update
# sudo apt install apache2
# sudo apache2ctl configtest
# sudo service apache2 restart

#########################################
#
# PHP Install
#
#########################################
# sudo add-apt-repository ppa:ondrej/php
# sudo apt update
# sudo apt install libapache2-mod-php7.0 -y
# sudo update-alternatives --config php

#########################################
#
# config file
#
#########################################
cat /var/www/base/httpd/local/httpd.conf | ssh local.tci "sudo tee /etc/apache2/sites-available/local.conf"
ssh local.tci "sudo sed -i 's/\/var\/www\/base\/httpd\/local\//\/home\/gssadmin\/.ssl\/\g/' /etc/apache2/sites-available/local.conf"

# #########################################
ssh local.tci "mkdir -p ~/.ssl"
scp /var/www/base/httpd/local/private.key local.tci:~/.ssl/
scp /var/www/base/httpd/local/certificate.crt local.tci:~/.ssl/

# ssh local.tci "
# sudo add-apt-repository ppa:certbot/certbot
# sudo apt update
# sudo apt install -y python-certbot-apache
# sudo certbot --apache
# "

# #########################################
ssh local.tci "
sudo mkdir -p /var/www/html/
sudo mkdir -p /var/www/html/dev/

sudo chmod 775 /var/www/html/
sudo chmod 775 /var/www/html/dev/

sudo usermod -aG www-data gssadmin
sudo chown -R gssadmin:www-data /var/www/html/
"

ssh local.tci "
# sudo apt install -y libapache2-mod-php7.0 php7.0 php7.0-mysql php7.0-mbstring php7.0-mysqli php7.0-intl php7.0-curl php7.0-gd php7.0-mcrypt php7.0-soap php7.0-dom php7.0-xml php7.0-zip

sudo a2ensite local.conf
sudo a2dismod php?.?
sudo a2enmod proxy proxy_http headers deflate expires rewrite mcrypt reqtimeout vhost_alias php7.0 ssl

sudo apache2ctl configtest
sudo service apache2 restart
sudo service apache2 status
"
