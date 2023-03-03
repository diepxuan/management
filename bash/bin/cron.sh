#!/usr/bin/env bash
#!/bin/bash

--cron:cronjob:min() {
    --cron:service
}

--cron:cronjob:5min() {
    --cron:install
    --sys:ufw
    # --dns:update
    --ddns:update
    if [[ $(--sys:env:debug) -eq 0 ]]; then
        --sys:selfupdate
        # else
        # echo "not update"
    fi
}

--cron:cronjob:hour() {
    # --ufw:geoip:configuration
    --cron:service
}

--cron:cronjob:month() {
    --ufw:geoip:configuration
}

_DUCTN_COMMANDS+=("cron:service")
--cron:service() {
    --cron:service:httpd
    --cron:service:mysql
    --cron:service:mssql
    --cron:service:ufw
}

--cron:service:httpd() {
    if [ "$(--sys:service:isactive apache2)" == "failed" ]; then
        --swap:install
        --log:cleanup
        sudo systemctl restart apache2
    fi

    # sudo /usr/sbin/service apache2 status | grep 'active' >/dev/null 2>&1
    # if [ $? != 0 ]; then
    #     sudo /usr/sbin/service apache2 start
    # fi
}

--cron:service:mysql() {
    if [ "$(--sys:service:isactive mysql)" == "failed" ]; then
        --swap:install
        --log:cleanup
        sudo systemctl restart mysql
    fi

    # sudo /usr/sbin/service mysql status | grep 'active' >/dev/null 2>&1
    # if [ $? != 0 ]; then
    #     --swap:install
    #     --log:cleanup
    #     sudo /usr/sbin/service mysql start
    # fi
}

--cron:service:mssql() {
    if [ "$(--sys:service:isactive mssql-server)" == "failed" ]; then
        --swap:install
        --log:cleanup
        sudo /usr/sbin/service mssql-server start
    fi

    # sudo /usr/sbin/service mssql-server status | grep 'active' >/dev/null 2>&1
    # if [ $? != 0 ]; then
    #     --swap:install
    #     --log:cleanup
    #     sudo /usr/sbin/service mssql-server start
    # fi
}

--cron:service:ufw() {
    if [ "$(--sys:service:isactive ufw)" == "failed" ]; then
        [[ $(--sys:ufw:is_exist) -eq 1 ]] && sudo ufw enable
    fi

    # sudo ufw status | grep ' active' >/dev/null 2>&1
    # if [ $? != 0 ]; then
    #     sudo ufw enable
    # fi
}

--cron:cronjob() {
    --cron:cronjob:5min
}

_DUCTN_COMMANDS+=("cron:update")
--cron:update() {
    --cron:cronjob:5min
}

_DUCTN_COMMANDS+=("cron:install")
--cron:install() { --cron:crontab:install; }
--cron:crontab:install() {
    if [ ! "$(--sys:service:isactive)" == "active" ]; then
        if [ "$(whoami)" = "ductn" ]; then
            # chmod u+x $_BASHDIR/cronjob/*.sh
            # chmod u+x $_BASHDIR/cronjob/cronjob
            crontab $_BASHDIR/cronjob/cronjob.conf
        fi
    fi
}

_DUCTN_COMMANDS+=("cron:uninstall")
--cron:uninstall() { --cron:crontab:uninstall; }
--cron:crontab:uninstall() {
    crontab -r
    sudo service cron restart
}
