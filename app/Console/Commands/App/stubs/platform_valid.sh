#!/usr/bin/env bash
#!/bin/bash

command -v add-apt-repository >/dev/null 2>&1 &&
    sudo grep -r "deb http://ppa.launchpad.net/ondrej/php/ubuntu" /etc/apt/sources.list /etc/apt/sources.list.d/ >/dev/null 2>&1 &&
    sudo add-apt-repository ppa:ondrej/php -y &&
    sudo apt update

sudo grep -r "deb http://ppa.launchpad.net/ondrej/php/ubuntu" /etc/apt/sources.list /etc/apt/sources.list.d/ >/dev/null 2>&1 &&
    cat <<EOF | sudo tee /etc/apt/sources.list.d/ondrej-ubuntu-php-focal.list >/dev/null &&
deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main
# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu focal main
EOF
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C &&
    sudo apt update

sudo apt install php%version%-cli php%version%-xml php%version%-dev -y

# ###########################

pecl shell-test runkit7 || pecl install runkit7-alpha

EXTENSION="runkit7"
MODS=$(find /etc/php/ -name "mods-available" -type d 2>/dev/null || echo '')
for DIR in \$MODS; do
    if [ ! -f "\${DIR}/\${EXTENSION}.ini" ]; then
        cat <<EOF | tee "\${DIR}/\${EXTENSION}.ini" >/dev/null
; configuration for pecl runkit7 module
; priority=20
extension=runkit7.so
runkit.internal_override=On
EOF
    fi
done

phpenmod runkit7

# ###########################

isExists=$(command -v add-apt-repository) &&
    [ ! -z $isExists ] &&
    isExistsRepository=$(sudo grep -r "deb http://ppa.launchpad.net/ondrej/php/ubuntu" /etc/apt/sources.list /etc/apt/sources.list.d/) &&
    [ ! -z $isExistsRepository ] &&
    sudo add-apt-repository ppa:ondrej/php -y &&
    sudo apt update

isExists=$(sudo grep -r "deb http://ppa.launchpad.net/ondrej/php/ubuntu" /etc/apt/sources.list /etc/apt/sources.list.d/) &&
    [ ! -z $isExists ] &&
    cat <<EOF | sudo tee /etc/apt/sources.list.d/ondrej-ubuntu-php-focal.list >/dev/null &&
deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main
# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu focal main
EOF
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C &&
    sudo apt update

sudo apt install php%version%-cli php%version%-xml php%version%-dev -y
