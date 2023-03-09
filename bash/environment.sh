#!/usr/bin/env bash
#!/bin/bash

. $_BASHDIR/environment.color.sh

_MYSQL_REPLICATE=""
_MYSQL_REPLICATE_TOOGLE=""
_MYSQL_REPLICATE_TOOGLE=""
_MYSQL_REPLICATE_HOST=0

DEBUG=0
DEV=0

USER_BIN_PATH=/home/ductn/bin
LOCAL_BIN_PATH=/usr/local/bin
DIRTMP=/tmp/ductn

SERVICE_DESC="Ductn service"
SERVICE_NAME=ductnd
# SERVICE_PATH="/var/www/base/bash/ductn.sh run_as_service"
SERVICE_PATH="$LOCAL_BIN_PATH/ductn run_as_service"

# Ket noi den vpn server
# _IPTUNEL="pve2:1.1.1.1"

# Danh sach domain luon luon allow
# DDNS_DOMAINS="domain1.diepxuan.com domain2.diepxuan.com"

# Load user environment
--sys:env:import
