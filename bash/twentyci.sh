#!/bin/bash

#########################################
# ssh magento.twentyci.asia "
# echo \"tciadmin ALL=(ALL) NOPASSWD:ALL\" | sudo tee /etc/sudoers.d/90-users

# # File server
# #########################################
# # sudo apt update
# # sudo apt install -y samba

# sudo mkdir -p /var/www/
# sudo mkdir -p /var/www/magento
# sudo chown -R tciadmin /var/www/

# # echo \"[Magento]
# #     comment = Magento Sharing
# #     path = /var/www/magento
# #      browseable = yes
# #     read only = no
# #     guest ok = yes
# #     writable = yes
# #     force user = gssadmin
# #     create mask = 0755
# #     directory mask = 0755
# # \" | sudo tee -a /etc/samba/smb.conf

# sudo service smbd restart

# # Firewall
# #########################################
# sudo ufw allow ssh
# sudo ufw allow http
# sudo ufw allow https
# sudo ufw allow mysql
# sudo ufw allow 8983/tcp
# "

#########################################
_newUser() {
    if [ -z $1 ]; then
        echo "# authorized"
        echo "#########################################"

        echo -en "# add authorized_keys ..."
        ssh-copy-id staging.part.twentyci.asia ${1} &>/dev/null
        ssh staging.part.twentyci.asia "chmod 600 ~/.ssh/*"

        cat /var/www/base/ssh/tci | ssh staging.part.twentyci.asia "
        cat > ~/.ssh/id_rsa
        ssh-keygen -f ~/.ssh/id_rsa -y > ~/.ssh/id_rsa.pub
        "
        echo -e \t\t "--ok"
    else
        echo -en $1@staging.part.twentyci.asia
        ssh staging.part.twentyci.asia -tt "
        id -u ${1} || sudo adduser ${1}
        sudo mkdir -p /home/${1}/.ssh

        cat ~/.ssh/id_rsa          | sudo tee /home/${1}/.ssh/id_rsa
        cat ~/.ssh/id_rsa.pub      | sudo tee /home/${1}/.ssh/id_rsa.pub
        cat ~/.ssh/authorized_keys | sudo tee /home/${1}/.ssh/authorized_keys

        sudo chmod    755       /home/${1}
        sudo chmod -R 600       /home/${1}/.ssh
        sudo chmod    700       /home/${1}/.ssh
        sudo chown -R ${1}:${1} /home/${1}/.ssh

        sudo mkdir -p           /home/${1}/public_html
        sudo mkdir -p           /home/${1}/public_html/csv
        sudo chown -R ${1}:${1} /home/${1}/public_html

        sudo mkdir -p           /home/${1}/.ssl
        sudo chown -R ${1}:${1} /home/${1}/.ssl

        sudo mkdir -p           /home/${1}/.mage
        sudo chmod -R 777       /home/${1}/.mage
        sudo chown -R ${1}:${1} /home/${1}/.mage
        " &>/dev/null
        echo -e \t\t "--ok"
    fi
}

_newUser
_newUser mrtperformance
_newUser fulcrumsuspensions

unset -f _newUser

echo ""
echo "# Setup"
echo "#########################################"
ssh -t staging.part.twentyci.asia "
curl -O https://files.magerun.net/n98-magerun2.phar &>/dev/null
chmod +x n98-magerun2.phar
sudo mv n98-magerun2.phar /usr/bin/magerun2
"

echo " - /etc/nginx/conf.d/configuration.conf"
scp /var/www/base/bash/twentyci/nginx/configuration.conf    staging.part.twentyci.asia:/tmp/ &>/dev/null
ssh -tt staging.part.twentyci.asia sudo mv -Z /tmp/configuration.conf  /etc/nginx/conf.d/configuration.conf

echo " - /etc/nginx/conf.d/magento.settings"
scp /var/www/base/bash/twentyci/nginx/magento.settings      staging.part.twentyci.asia:/tmp/ &>/dev/null
ssh -tt staging.part.twentyci.asia sudo mv -Z /tmp/magento.settings    /etc/nginx/conf.d/magento.settings


echo ""
echo "# php-fpm"
echo "#########################################"

scp /var/www/base/bash/twentyci/phpfpm/mrtperformance.conf  staging.part.twentyci.asia:/tmp/ &>/dev/null
ssh -tt staging.part.twentyci.asia sudo mv -Z /tmp/mrtperformance.conf /etc/php-fpm.d/mrtperformance.conf
echo " - /etc/php-fpm.d/mrtperformance.conf"

scp /var/www/base/bash/twentyci/phpfpm/fulcrumsuspensions.conf  staging.part.twentyci.asia:/tmp/ &>/dev/null
ssh -tt staging.part.twentyci.asia sudo mv -Z /tmp/fulcrumsuspensions.conf /etc/php-fpm.d/fulcrumsuspensions.conf
echo " - /etc/php-fpm.d/fulcrumsuspensions.conf"

ssh -t staging.part.twentyci.asia sudo systemctl restart php-fpm


echo ""
echo "# nginx"
echo "#########################################"

scp /var/www/base/bash/twentyci/nginx/mrtperformance.conf   staging.part.twentyci.asia:/tmp/ &>/dev/null
ssh -tt staging.part.twentyci.asia sudo mv -Z /tmp/mrtperformance.conf /etc/nginx/conf.d/mrtperformance.conf
echo " - /etc/nginx/conf.d/mrtperformance.conf"

scp /var/www/base/bash/twentyci/nginx/fulcrumsuspensions.conf   staging.part.twentyci.asia:/tmp/ &>/dev/null
ssh -tt staging.part.twentyci.asia sudo mv -Z /tmp/fulcrumsuspensions.conf /etc/nginx/conf.d/fulcrumsuspensions.conf
echo " - /etc/nginx/conf.d/fulcrumsuspensions.conf"

ssh -t staging.part.twentyci.asia sudo nginx -t
ssh -t staging.part.twentyci.asia sudo systemctl restart nginx


echo ""
echo "# deploy"
echo "#########################################"

scp /var/www/base/bash/twentyci/deploy/mrtperformance.sh    mrtperformance@staging.part.twentyci.asia:/home/mrtperformance/public_html/deploy.sh &>/dev/null
ssh mrtperformance@staging.part.twentyci.asia chmod u+x /home/mrtperformance/public_html/deploy.sh
echo " - mrtperformance deploy.sh"

scp /var/www/base/bash/twentyci/deploy/fulcrumsuspensions.sh    fulcrumsuspensions@staging.part.twentyci.asia:/home/fulcrumsuspensions/public_html/deploy.sh &>/dev/null
ssh fulcrumsuspensions@staging.part.twentyci.asia chmod u+x /home/fulcrumsuspensions/public_html/deploy.sh
echo " - fulcrumsuspensions deploy.sh"

exit
