#!/usr/bin/env bash
#!/bin/bash
#!/bin/sh

BIN=ductn.phar
PHP=$(which php)
php_required=8.1

[[ ! $(whoami) -eq 'ductn' ]] && exit 1

__php_path_get() {
    sudo update-alternatives --list php | grep .default -v | sort | grep 8.0 -v | grep 8. | head -n 1
}

__php_path_install() {
    sudo apt install -y php$php_required-cli \
        php$php_required-xml \
        php$php_required-dev \
        php$php_required-curl \
        php$php_required-mysql \
        php$php_required-runkit7 \
        php$php_required-mbstring >/dev/null
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

PHP=$(__php_path)

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
