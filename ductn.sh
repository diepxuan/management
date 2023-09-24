#!/usr/bin/env bash
#!/bin/bash
#!/bin/sh

BIN=ductn.phar

[[ ! $(whoami) -eq 'ductn' ]] && exit 1

__pecl() {
    sudo pecl $*
    return
    phpvers=$(sudo update-alternatives --list php | grep .default -v | sed 's|/usr/bin/php||g')
    for phpver in $phpvers; do
        sudo pecl -d php_suffix=$phpver $*
    done
}

__php_pecl_runkit7() {
    [[ -z $(pecl shell-test runkit7 2>&1) ]] && return

    __pecl uninstall runkit7-alpha
    __pecl install runkit7-alpha
}

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

__php_alternatives
__php_ext_runkit7

__SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f $(which $BIN) ]] && BIN=$(which $BIN)
[[ -f $__SCRIPT_DIR/$BIN ]] && BIN=$__SCRIPT_DIR/$BIN
[[ -f $__SCRIPT_DIR/artisan ]] && BIN=$__SCRIPT_DIR/artisan

while true; do
    # echo "run_as_service"
    php $BIN $*
    [[ ! "$*" =~ "run_as_service" ]] && exit 0
    sleep 1
done

# Use exec to replace the current script process with a new one
# exec "$0"

exit 0
