#!/usr/bin/env bash
#!/bin/bash

_BASEDIR="/var/www/base"
_BASHDIR="$_BASEDIR/bash"

--cron:cronjob:min() {
    --cron:service
}

--cron:cronjob:5min() {
    --cron:update
}

--cron:cronjob:hour() {
    # --ufw:geoip:configuration
}

--cron:cronjob:month() {
    --ufw:geoip:configuration
}

--cron:service() {
    --cron:service:httpd
    --cron:service:mysql
    --cron:service:mssql
    --cron:service:ufw
}

--cron:service:httpd() {
    sudo /usr/sbin/service apache2 status | grep 'active' >/dev/null 2>&1
    if [ $? != 0 ]; then
        sudo /usr/sbin/service apache2 start
    fi
}

--cron:service:mysql() {
    sudo /usr/sbin/service mysql status | grep 'active' >/dev/null 2>&1
    if [ $? != 0 ]; then
        $_BASHDIR/ductn swap:install
        $_BASHDIR/ductn log:cleanup
        sudo /usr/sbin/service mysql start
    fi
}

--cron:service:mssql() {
    sudo /usr/sbin/service mssql-server status | grep 'active' >/dev/null 2>&1
    if [ $? != 0 ]; then
        $_BASHDIR/ductn swap:install
        $_BASHDIR/ductn log:cleanup
        sudo /usr/sbin/service mssql-server start
    fi
}

--cron:service:ufw() {
    sudo ufw status | grep ' active' >/dev/null 2>&1
    if [ $? != 0 ]; then
        sudo ufw enable
    fi
}

--cron:update() {
    --cron:install
    --sys:ufw
    # --dns:update
    --ddns:update
    if [[ $(--sys:env:debug) -eq 1 ]]; then
        --sys:selfupdate
        # else
        # echo "not update"
    fi
}

--cron:install() {
    --cron:crontab:install
}

--cron:crontab:install() {
    if [ "$(whoami)" = "ductn" ]; then
        # chmod u+x $_BASHDIR/cronjob/*.sh
        # chmod u+x $_BASHDIR/cronjob/cronjob
        crontab $_BASHDIR/cronjob/cronjob.conf
    fi
}
