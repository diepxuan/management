#!/usr/bin/env bash
#!/bin/bash
#!/bin/sh

BIN=ductn.phar

[[ ! $(whoami) -eq 'ductn' ]] && exit 1

__php_install_ppa() {
    sudo grep -r "deb http://ppa.launchpad.net/ondrej/php/ubuntu" /etc/apt/sources.list /etc/apt/sources.list.d/*.list >/dev/null 2>&1 && return

    command -v add-apt-repository >/dev/null 2>&1 && (
        sudo add-apt-repository ppa:ondrej/php -y
    ) || (
        cat <<EOF | sudo tee /etc/apt/sources.list.d/ondrej-ubuntu-php-focal.list >/dev/null &&
deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main
# deb-src http://ppa.launchpad.net/ondrej/php/ubuntu focal main
EOF
            sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
    )

    sudo apt update
}

__pecl() {
    sudo pecl $*
    return
    phpvers=$(sudo update-alternatives --list php | grep .default -v | sed 's|/usr/bin/php||g')
    for phpver in $phpvers; do
        sudo pecl -d php_suffix=$phpver $*
    done
}

__php_ext_runkit7() {
    [[ -z $(pecl shell-test runkit7 2>&1) ]] && return
    php -m | grep runkit7 >/dev/null 2>&1 && return

    EXTENSION="runkit7"
    MODS=$(find /etc/php/ -name "mods-available" -type d 2>/dev/null || echo '')

    __pecl uninstall runkit7-alpha
    __pecl install runkit7-alpha
    for DIR in $MODS; do
        if [ ! -f "${DIR}/${EXTENSION}.ini" ]; then
            cat <<EOF | sudo tee "${DIR}/${EXTENSION}.ini" >/dev/null
; configuration for pecl runkit7 module
; priority=20
extension=runkit7.so
runkit.internal_override=On
EOF
        fi
    done
    sudo phpenmod runkit7
}

__php_alternatives() {
    selected=$(sudo update-alternatives --get-selections | grep /usr/bin/php | awk '{print $3}' | head -n 1 | sed 's|/usr/bin/php||g')
    mod=$(sudo update-alternatives --get-selections | grep /usr/bin/php | awk '{print $2}' | head -n 1 | sed 's|/usr/bin/php||g')

    [[ "$mode" == "auto" ]] &&
        sudo update-alternatives --auto phpize ||
        sudo update-alternatives --set phpize /usr/bin/phpize$selected

    [[ "$mode" == "auto" ]] &&
        sudo update-alternatives --auto php-config ||
        sudo update-alternatives --set php-config /usr/bin/php-config$selected
}

__php_alternatives
__php_ext_runkit7

which $BIN >/dev/null && php $(which $BIN) $* || php $BIN $*
exit 0
