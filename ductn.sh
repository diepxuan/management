#!/usr/bin/env bash
#!/bin/bash
#!/bin/sh

BIN=ductn.phar
PHP=$(which php)
php_required=8.1

[[ ! $(whoami) -eq 'ductn' ]] && exit 1

if [[ ! $(realpath $0) == '/var/www/base/ductn.sh' && -f /var/www/base/ductn.sh ]]; then
    bash /var/www/base/ductn.sh $*
    exit
fi

__php_path_ppa() {
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

__php_path_get() {
    sudo update-alternatives --list php | grep .default -v | sort | grep 8.0 -v | grep 8. | head -n 1
}

__php_path_install() {
    __php_path_ppa >/dev/null
    sudo apt install -y php$php_required-cli php$php_required-xml php$php_required-dev php$php_required-curl php$php_required-mysql php$php_required-mbstring >/dev/null
    echo $(__php_path_get)
}

__php_path_load() {
    php_path=$(__php_path_get)
    [[ ! -z $php_path ]] && echo $php_path || echo $(__php_path_install)
}

__php_path() {
    command -v php >/dev/null 2>&1 || __php_path_install
    php_version=$(php -v | head -n 1 | awk '{print $2}' | cut -d '.' -f 1,2)

    php_valid=$(echo "$php_version
$php_required" | sort -V | head -n 1)

    [[ $php_valid == $php_required ]] && echo $(which php) || echo $(__php_path_load)
}

__pecl() {
    sudo pecl -d php_suffix=$PHP $*
}

__php_pecl_runkit7() {
    [[ -z $(pecl shell-test runkit7 2>&1) ]] && return

    __pecl uninstall runkit7
    __pecl install runkit7-alpha
}

# kiem tra va enable module runkit7
__php_ext_runkit7() {
    __php_pecl_runkit7
    php -m | grep runkit7 >/dev/null 2>&1 && return

    EXTENSION="runkit7"
    MODS=$(find /etc/php/ -name "mods-available" -type d 2>/dev/null || echo '')
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

# chuyen cac module sang dung cung version voi php
__php_alternatives() {
    selected=$(sudo update-alternatives --get-selections | grep /usr/bin/php | awk '{print $3}' | head -n 1 | sed 's|/usr/bin/php||g')
    mod=$(sudo update-alternatives --get-selections | grep /usr/bin/php | awk '{print $2}' | head -n 1 | sed 's|/usr/bin/php||g')

    sudo update-alternatives --set phpize /usr/bin/phpize$selected >/dev/null 2>&1
    [[ "$mode" == "auto" ]] && sudo update-alternatives --auto phpize >/dev/null 2>&1

    sudo update-alternatives --set php-config /usr/bin/php-config$selected >/dev/null 2>&1
    [[ "$mode" == "auto" ]] && sudo update-alternatives --auto php-config >/dev/null 2>&1

    sudo update-alternatives --set phar /usr/bin/phar$selected >/dev/null 2>&1
    [[ "$mode" == "auto" ]] && sudo update-alternatives --auto phar >/dev/null 2>&1

    sudo update-alternatives --set phar.phar /usr/bin/phar.phar$selected >/dev/null 2>&1
    [[ "$mode" == "auto" ]] && sudo update-alternatives --auto phar.phar >/dev/null 2>&1
}

PHP=$(__php_path)
# __php_alternatives
# __php_ext_runkit7

__SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f $(which $BIN) ]] && __BIN=$(which $BIN)
[[ -f $__SCRIPT_DIR/$BIN ]] && __BIN=$__SCRIPT_DIR/$BIN
[[ -f $__SCRIPT_DIR/artisan ]] && __BIN=$__SCRIPT_DIR/artisan
BIN=$__BIN

while true; do
    # echo "run_as_service"
    $PHP -d phar.readonly=off $BIN $*
    [[ ! "$*" =~ "run_as_service" ]] && exit 0
    sleep 1
done

# Use exec to replace the current script process with a new one
# exec "$0"

exit 0
