#!/bin/bash

if [[ ! "$(/usr/sbin/service mysql status)" =~ "start/running" ]]
then
    rm -rf /swapfile
    fallocate -l 5G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    /usr/sbin/service mysql start
fi

if [[ ! "$(/usr/sbin/service mysql status)" =~ "start/running" ]]
then
    /usr/sbin/service mysql status
fi
