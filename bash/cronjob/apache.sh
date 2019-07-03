#!/bin/bash

if [[ ! "$(sudo /usr/sbin/service apache2 status)" =~ "start/running" ]]; then
  sudo /usr/sbin/service apache2 start
fi
