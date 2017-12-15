#!/bin/bash

####################################
#
# completion
#
####################################
echo ". ~/public_html/code/bash/.bash_aliases" > ~/.bash_aliases
chmod 644 ~/.bash_aliases
~/public_html/code/bash/completion/magerun.setup
~/public_html/code/bash/completion/magerun2.setup
source ~/.bashrc

####################################
#
# tmux
#
####################################
# cat ~/public_html/code/bash/.tmux.conf > ~/.tmux.conf
# chmod 644 ~/.tmux.conf

####################################
#
# git
#
####################################
cat ~/public_html/code/bash/git/.gitignore > ~/.gitignore
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
mkdir -p ~/.ssh
chmod 700 ~/.ssh
# ssh config
cat ~/public_html/code/ssh/config > ~/.ssh/config
find ~/public_html/code/ssh/config.d/*.conf -type f -exec cat {} >> ~/.ssh/config \; -exec printf "\n\n" >> ~/.ssh/config \;
cat ~/public_html/code/ssh/id_rsa | ssh diepxuan "cat > ~/.ssh/id_rsa"
cat ~/public_html/code/ssh/id_rsa.pub | ssh diepxuan "cat > ~/.ssh/id_rsa.pub"

# ssh private key
cat ~/public_html/code/ssh/id_rsa > ~/.ssh/id_rsa
cat ~/public_html/code/ssh/gss > ~/.ssh/gss
cat ~/public_html/code/ssh/tci > ~/.ssh/tci
chmod 600 ~/.ssh/*

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
sudo apt install phpmd -y

cat ~/public_html/code/httpd/httpd.conf | sudo tee /etc/apache2/sites-available/ductn.conf

sudo apt install -y libapache2-mod-php?.? php?.? php?.?-mysql php?.?-mbstring php?.?-mysqli php?.?-intl php?.?-curl php?.?-gd php?.?-mcrypt php?.?-soap php?.?-dom php?.?-xml php?.?-zip

sudo a2ensite ductn.conf
sudo a2dismod php?.?
sudo a2enmod proxy proxy_http headers deflate expires rewrite mcrypt reqtimeout vhost_alias php7.0 ssl

sudo service apache2 restart
sudo service apache2 status
