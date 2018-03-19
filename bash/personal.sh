#!/bin/bash

####################################
#
# tmux
#
####################################
# cat /var/www/base/bash/.tmux.conf > ~/.tmux.conf
# chmod 644 ~/.tmux.conf

####################################
#
# git
#
####################################
cat /var/www/base/tool/.gitignore > ~/.gitignore
chmod 644 ~/.gitignore

# global gitignore
git config --global core.excludesfile ~/.gitignore

# setting
git config --global user.name "Trần Ngọc Đức"
git config --global user.email "caothu91@gmail.com"

# push
git config --global push.default simple

# file mode
git config --global core.fileMode false

# line endings
git config --global core.autocrlf false
git config --global core.eol lf

# Cleanup
git config --global gc.auto 0

####################################
#
# SSH
#
####################################
# Create PEM file
# ##############################
#
# openssl rsa -in id_rsa -outform PEM -out id_rsa.pem
# openssl x509 -outform der -in id_rsa.pem -out id_rsa.crt

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
# ssh-keygen -t rsa -y > ~/.ssh/id_rsa.pub
# ssh-keygen -f id_rsa -p

# Setup
# ##############################
mkdir -p ~/.ssh
# ssh config
cat /var/www/base/ssh/config > ~/.ssh/config
printf "\n\n" >> ~/.ssh/config
find /var/www/base/ssh/config.d/*.conf -type f -exec cat {} >> ~/.ssh/config \; -exec printf "\n\n" >> ~/.ssh/config \;

# ssh private key
cat /var/www/base/ssh/id_rsa > ~/.ssh/id_rsa
cat /var/www/base/ssh/gss > ~/.ssh/gss
cat /var/www/base/ssh/tci > ~/.ssh/tci
cat /var/www/base/ssh/gem > ~/.ssh/gem

chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

ssh-keygen -f ~/.ssh/id_rsa -y > ~/.ssh/id_rsa.pub
ssh-keygen -f ~/.ssh/gss -y > ~/.ssh/gss.pub
ssh-keygen -f ~/.ssh/tci -y > ~/.ssh/tci.pub
ssh-keygen -f ~/.ssh/gem -y > ~/.ssh/gem.pub

# ssh-copy-id user@123.45.56.78

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
# sudo apt install phpmd -y
# sudo apt install composer -y --purge --auto-remove

#########################################
#
# SSL Install
#
#########################################
mkdir -p ~/.ssl
chmod 775 ~/.ssl
# ssh config
cp -a /var/www/base/httpd/* ~/.ssl
find ~/.ssl -type f -name '*.conf' -delete

#########################################
#
# vhost Install
#
#########################################
cat /var/www/base/httpd/httpd.conf | sudo tee /etc/apache2/sites-available/ductn.conf
printf "\n\n" >> /etc/apache2/sites-available/ductn.conf
find /var/www/base/httpd/*/httpd.conf -type f -exec cat {} \;| sudo tee -a /etc/apache2/sites-available/ductn.conf

# sudo apt install -y libapache2-mod-php?.? php?.? php?.?-mysql php?.?-mbstring php?.?-mysqli php?.?-intl php?.?-curl php?.?-gd php?.?-mcrypt php?.?-soap php?.?-dom php?.?-xml php?.?-zip

sudo a2ensite ductn.conf
sudo a2dismod php?.?
sudo a2enmod proxy proxy_http headers deflate expires rewrite mcrypt reqtimeout vhost_alias php7.0 ssl

sudo apache2ctl configtest
sudo service apache2 restart
# sudo service apache2 status

#########################################
#
# sendMail Install
#
#########################################
# sudo apt install -y sendmail
# cd /etc/mail/tls
# sudo openssl dsaparam -out sendmail-common.prm 2048
# sudo chown root:smmsp sendmail-common.prm
# sudo chmod 0640 sendmail-common.prm
# sudo dpkg --configure -a

#########################################
#
# Nodejs Install
#
#########################################
# curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
# sudo apt install -y nodejs build-essential

# echo "fs.inotify.max_user_watches = 524288" | sudo tee /etc/sysctl.d/grunt.conf
# sudo sysctl -p --system

# Java install
#########################################
# sudo add-apt-repository ppa:webupd8team/java
# sudo apt update
# sudo apt install -y oracle-java9-installer

# Solr install
#########################################
# cd /opt
# sudo service solr stop
# sudo rm -rf /etc/init.d/solr
# sudo rm -rf solr* install_solr_service.sh

# sudo wget https://www-eu.apache.org/dist/lucene/solr/7.1.0/solr-7.1.0.tgz
# sudo tar xzf solr-7.1.0.tgz solr-7.1.0/bin/install_solr_service.sh --strip-components=2
# sudo bash ./install_solr_service.sh solr-7.1.0.tgz

# sudo wget https://archive.apache.org/dist/lucene/solr/6.1.0/solr-6.1.0.tgz
# sudo tar xzf solr-6.1.0.tgz solr-6.1.0/bin/install_solr_service.sh --strip-components=2
# sudo ./install_solr_service.sh solr-6.1.0.tgz -f

# sudo wget http://mirrors.viethosting.com/apache/lucene/solr/6.6.2/solr-6.6.2.tgz
# sudo tar xzf solr-6.6.2.tgz solr-6.6.2/bin/install_solr_service.sh --strip-components=2
# sudo ./install_solr_service.sh solr-6.6.2.tgz -f

# sudo service solr restart
# sudo usermod -aG solr `whoami`

####################################
#
# completion
#
####################################
echo ". /var/www/base/bash/.bash_aliases" > ~/.bash_aliases
chmod 644 ~/.bash_aliases

# composer -vvv global require bamarni/symfony-console-autocomplete
chmod u+x /var/www/base/bash/completion/*.setup
# /var/www/base/bash/completion/magerun.setup
# /var/www/base/bash/completion/magerun2.setup
mkdir -p ~/bin
chmod 775 -R ~/bin

#########################################
#
# Deploy Install
#
#########################################
sudo crontab /var/www/base/bash/deploy/deploy.conf
sudo service cron restart
