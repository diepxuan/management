#!/usr/bin/env bash
#!/bin/bash

_HTTPDDIR="$_LIBDIR/httpd"

_DUCTN_COMMANDS+=("httpd:install")
--httpd:install() {
    #!/usr/bin/env bash

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

    # sudo apt-get install libapache2-mpm-itk
    # sudo a2enmod mpm_itk

    sudo a2enmod proxy proxy_http headers deflate expires rewrite mcrypt reqtimeout vhost_alias ssl env dir mime &>/dev/null

    # sudo a2dismod php?.?
    # sudo a2enmod php7.1

    sudo apache2ctl configtest
    sudo service apache2 restart
    # sudo service apache2 status

}

_DUCTN_COMMANDS+=("httpd:config")
--httpd:config() {
    --chmod() {
        --httpd:config:chmod
    }

    --httpd:config:sites
}

--httpd:config:chmod() {
    sudo mkdir -p /home/pma/public_html/tmp
    sudo rm -rf /home/pma/public_html/config.inc.php
    sudo ln $_HTTPDDIR/diepxuan.com/config.inc.php /home/pma/public_html/
    sudo chmod -R 777 /home/pma/public_html/tmp

    sudo chown -R :www-data /home/*/public_html/
}

--httpd:config:sites() {
    # CREATE ductn SITE
    ###################
    #shellcheck disable=SC2002
    cat $_HTTPDDIR/httpd.conf | sudo tee /etc/apache2/sites-available/ductn.conf
    printf "\n\n" | sudo tee -a /etc/apache2/sites-available/ductn.conf
    # find $_HTTPDDIR/*/httpd.conf $_HTTPDDIR/*/httpd.conf.d/ -type f -exec cat {} \; | sudo tee -a /etc/apache2/sites-available/ductn.conf
    find $_HTTPDDIR/*/httpd.conf $_HTTPDDIR/*/httpd.conf.d/*.conf -type f | sort -n | xargs cat | sudo tee -a /etc/apache2/sites-available/ductn.conf
}

_DUCTN_COMMANDS+=("httpd:restart")
--httpd:restart() {
    --httpd:config $@
    sudo service apache2 restart
}