#!/usr/bin/env bash

# nodejs
sudo apt install -y nodejs nodejs-legacy npm

# Create a SSL Certificate on Apache
sudo mkdir /etc/apache2/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt

You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:VN
State or Province Name (full name) [Some-State]:HaNoi
Locality Name (eg, city) []:DXVN
Organization Name (eg, company) [Internet Widgits Pty Ltd]:DiepXuan
Organizational Unit Name (eg, section) []:Tran Ngoc Duc
Common Name (e.g. server FQDN or YOUR name) []:Tran Ngoc Duc
Email Address []:caothu91@gmail.com


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
sudo apt install libapache2-mod-php*.* -y
sudo update-alternatives --config php

#########################################
# User/Group
#########################################
# useradd -G foo,bar,ftp tom
# -m	Create the home directory if it does not exist.
# -d<home-dir>	Home directory to be used instead of default /home/<username>/
# -n	Do not create a user private group for the user.
# -s /bin/bash sam
# passwd <username>
# default folder /etc/skel
# useradd -g www-data -G ftp -s /bin/bash -m Username
# Ubuntu Linux: add a new user to secondary group
useradd -G www-data Username
passwd Username

# Ubuntu Linux: add a new user to primary group
useradd -g www tom

# Ubuntu Linux: add a existing user to existing group
usermod -a -G ftp jerry

# Ubuntu Linux: change primary group
usermod -g www jerry

# Delete a User
deluser --remove-home newuser

# Verify
id tom
groups tom


#########################################
# FTP Install
#########################################
sudo apt update
sudo apt install vsftpd -y

#########################################
# MySQL Install
#########################################

sudo apt install mysql-server -y
