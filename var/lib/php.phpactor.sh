#!/usr/bin/env bash
#!/bin/bash

_phpactor_install() {
    curl -O https://github.com/phpactor/phpactor/releases/latest/download/phpactor.phar &&
        chmod +x phpactor.phar &&
        mkdir -p /var/lib/ductn/ &&
        mv phpactor.phar /var/lib/ductn/phpactor.phar
}

_phpactor() {
    [[ ! -f /var/lib/ductn/phpactor.phar ]] && _phpactor_install
    /var/lib/ductn/phpactor.phar $@
}

d_phpactor() {
    _phpactor $@ && exit 0
}
