#!/bin/bash

if [[ ! "$(sudo /usr/sbin/service mysql status)" =~ "start/running" ]]; then
  sudo rm -rf /swapfile
  sudo fallocate -l 5G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  sudo /usr/sbin/service mysql start
fi
