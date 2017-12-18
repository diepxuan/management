#!/bin/bash

#########################################
#
# Clean
#
#########################################
ssh gsmartsolutions.local "
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
cat ~/public_html/code/bash/.bash_aliases | ssh gsmartsolutions.local "cat > ~/.bash_aliases"
ssh gsmartsolutions.local "mkdir -p ~/.completion"
scp -r ~/public_html/code/bash/completion/*.sh gsmartsolutions.local:~/.completion/
ssh gsmartsolutions.local "chmod 775 ~/.completion"

####################################
#
# git
#
####################################
cat ~/public_html/code/bash/git/.gitignore | ssh gsmartsolutions.local "cat > ~/.gitignore"
ssh gsmartsolutions.local "
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
ssh gsmartsolutions.local "
mkdir -p ~/.ssh
chmod 700 ~/.ssh
"
# cat ~/public_html/code/ssh/gss.pub | ssh gsmartsolutions.local "cat >> ~/.ssh/authorized_keys"

# ssh private key
cat ~/public_html/code/ssh/gss | ssh gsmartsolutions.local "cat > ~/.ssh/id_rsa"
ssh gsmartsolutions.local "chmod 600 ~/.ssh/*"

# echo  "
# Host tci.staging
#     HostName 128.199.118.164
#     User gssadmin
# " | ssh gsmartsolutions.local "cat >> ~/.ssh/config"

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
# sudo apt install libapache2-mod-php?.? -y
# sudo update-alternatives --config php

#########################################
#
# config file
#
#########################################
cat ~/public_html/code/httpd/gss.conf | ssh gsmartsolutions.local "sudo tee /etc/apache2/sites-available/gss.conf"

#########################################
ssh gsmartsolutions.local "mkdir -p ~/.ssl"
scp ~/public_html/code/httpd/local/private.key gsmartsolutions.local:~/.ssl/
scp ~/public_html/code/httpd/local/certificate.crt gsmartsolutions.local:~/.ssl/

# ssh gsmartsolutions.local "
# sudo add-apt-repository ppa:certbot/certbot
# sudo apt update
# sudo apt install -y python-certbot-apache
# sudo certbot --apache

# "

#########################################
ssh gsmartsolutions.local "
sudo apt install -y libapache2-mod-php?.? php?.? php?.?-mysql php?.?-mbstring php?.?-mysqli php?.?-intl php?.?-curl php?.?-gd php?.?-mcrypt php?.?-soap php?.?-dom php?.?-xml php?.?-zip

sudo a2ensite gss.conf
sudo a2dismod php?.?
sudo a2enmod proxy proxy_http headers deflate expires rewrite mcrypt reqtimeout vhost_alias php7.0 ssl

sudo service apache2 restart
sudo service apache2 status
"
