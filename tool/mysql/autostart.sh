#!/bin/bash

# if [[ ! "$(sudo /usr/sbin/service apache2 status)" =~ "start/running" ]]
# then
#     sudo /usr/sbin/service apache2 restart
# fi

# if [[ ! "$(sudo /usr/sbin/service mysql status)" =~ "start/running" ]]
# then
#     sudo rm -rf /swapfile
#     sudo fallocate -l 5G /swapfile
#     sudo chmod 600 /swapfile
#     sudo mkswap /swapfile
#     sudo swapon /swapfile
#     sudo /usr/sbin/service mysql start
# fi

# if [[ ! "$(sudo /usr/sbin/service mysql status)" =~ "start/running" ]]
# then
#     sudo /usr/sbin/service mysql status
# fi

LOG=/var/log/mysql_restarter.log
MYSQL_STATUS="$(sudo /usr/sbin/service mysql status | grep running)"
HTTPD_STATUS="$(sudo /usr/sbin/service apache2 status | grep running)"

if [ -z "$MYSQL_STATUS" ]
then
    sudo swapoff --all
    sudo rm -rf /swapfile
    sudo fallocate -l 5G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    sudo /usr/sbin/service mysql start
    echo "$(date -R) mySql" >> $LOG
fi

if [ -z "$HTTPD_STATUS" ]
then
    sudo /usr/sbin/service apache2 start
    echo "$(date -R) apache2" >> $LOG
fi
