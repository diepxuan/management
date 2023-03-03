#!/usr/bin/env bash
#!/bin/bash

. $_BASHDIR/environment.color.sh

_MYSQL_REPLICATE=""
_MYSQL_REPLICATE_TOOGLE=""
_MYSQL_REPLICATE_TOOGLE=""
_MYSQL_REPLICATE_HOST=0

DEBUG=0
DEV=0

DIRTMP="/tmp/ductn"
ETC_HOSTS=/etc/hosts

SERVICE_DESC="Ductn service"
SERVICE_NAME=ductnd
# SERVICE_PATH="/var/www/base/bash/ductn.sh run_as_service"
SERVICE_PATH="/usr/local/bin/ductn run_as_service"

_DUCTN_COMMANDS=()

_IPTUNEL=("pve2:35.230.52.242")

_HOSTS=("pve2.vpn:35.230.52.242")

_DDNS_DOMAINS="dc1.diepxuan.com dc2.diepxuan.com dc3.diepxuan.com dx1.diepxuan.com dx2.diepxuan.com dx3.diepxuan.com sql1.diepxuan.com sql2.diepxuan.com"
