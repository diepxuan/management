#!/bin/bash

# sudoer
#########################################
ssh magento.tci "
echo \"tciadmin ALL=(ALL) NOPASSWD:ALL\" | sudo tee /etc/sudoers.d/90-users
"

# File server
#########################################
ssh magento.tci "
# sudo apt update
# sudo apt install -y samba
"

ssh magento.tci "
sudo mkdir -p /var/www/
sudo mkdir -p /var/www/magento
sudo chown -R tciadmin /var/www/

# echo \"[Magento]
#     comment = Magento Sharing
#     path = /var/www/magento
#      browseable = yes
#     read only = no
#     guest ok = yes
#     writable = yes
#     force user = gssadmin
#     create mask = 0755
#     directory mask = 0755
# \" | sudo tee -a /etc/samba/smb.conf

sudo service smbd restart
"

# Firewall
#########################################
ssh magento.tci "
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow mysql
sudo ufw allow 8983/tcp
"
