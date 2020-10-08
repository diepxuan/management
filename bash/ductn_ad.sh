#!/bin/bash

# sudo hostnamectl set-hostname dc1
# echo "35.232.100.140  dc1 dc1.ad.diepxuan.com" | sudo tee /etc/hosts

# sudo hostnamectl set-hostname ad
# echo "125.212.237.119 ad.diepxuan.com ad" | sudo tee /etc/hosts

sudo apt install samba smbclient winbind libpam-winbind libnss-winbind krb5-kdc libpam-krb5 -y --purge --auto-remove
# sudo apt install samba libpam-winbind -y

sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.orig
sudo mv /etc/krb5.conf /etc/krb5.conf.orig

sudo samba-tool domain provision --use-rfc2307 --interactive
# sudo cp /var/lib/samba/private/krb5.conf /etc
sudo ln -s /var/lib/samba/private/krb5.conf /etc/
host -t SRV _ldap._tcp.ad.diepxuan.com
host -t SRV _kerberos._udp.ad.diepxuan.com
host -t A ad.diepxuan.com

# sudo netstat -tulpn | grep :53
# sudo systemctl stop systemd-resolved
# sudo systemctl disable systemd-resolved
# sudo unlink /etc/resolv.conf
# printf "nameserver 35.232.100.140
# search ad.diepxuan.com" >> /etc/resolv.conf
# sudo reboot

kinit Administrator
klist

sudo systemctl mask smbd nmbd winbind
sudo systemctl disable smbd nmbd winbind
sudo systemctl stop smbd nmbd winbind
sudo systemctl unmask samba-ad-dc
sudo systemctl start samba-ad-dc
sudo systemctl enable samba-ad-dc

# sudo samba-tool user create user1

# https://www.linuxbabe.com/linux-server/setup-your-own-pptp-vpn-server-on-debian-ubuntu-centos
