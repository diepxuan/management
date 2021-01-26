#!/bin/sh

--install() {
    #!/usr/bin/env bash

    # sudo apt-get install libapache2-mpm-itk
    # sudo a2enmod mpm_itk

    # CREATE ductn SITE
    ###################
    #shellcheck disable=SC2002
    cat /var/www/base/httpd/httpd.conf | sudo tee /etc/apache2/sites-available/ductn.conf
    printf "\n\n" >>/etc/apache2/sites-available/ductn.conf
    find /var/www/base/httpd/*/httpd.conf -type f -exec cat {} \; | sudo tee -a /etc/apache2/sites-available/ductn.conf

    # CREATE Dav Access
    ###################
    # mkdir -p /var/www/DavLock
    sudo a2enmod dav dav_fs auth_digest &>/dev/null
    sudo chmod 775 /var/www/
    sudo chown :www-data /var/www/

    # APPLY APACHE CONFIG
    #####################
    sudo a2ensite ductn.conf
    # sudo a2dismod mpm_prefork mpm_worker mpm_event
    sudo a2enmod proxy proxy_http headers deflate expires rewrite mcrypt reqtimeout vhost_alias ssl env dir mime &>/dev/null
    # sudo a2dismod php?.?
    # sudo a2enmod php7.1

    sudo apache2ctl configtest
    sudo service apache2 restart
    # sudo service apache2 status

}

-i() {
    --install
}

--config() {
    sudo mkdir -p /home/pma/public_html/tmp
    sudo rm -rf /home/pma/public_html/config.inc.php
    sudo ln /var/www/base/httpd/diepxuan.com/config.inc.php /home/pma/public_html/
    sudo chmod -R 777 /home/pma/public_html/tmp

    sudo mkdir -p /home/cloud/public_html/cloud
    sudo chmod -R 777 /home/cloud/public_html/cloud

    sudo chown -R :www-data /home/*/public_html/
}

$@
