#!/bin/bash

if [[ ! "$(/usr/sbin/service mysql status)" =~ "start/running" ]]
then
    /usr/sbin/service mysql start
fi

if [[ ! "$(/usr/sbin/service mysql status)" =~ "start/running" ]]
then
    /usr/sbin/service mysql status
fi
