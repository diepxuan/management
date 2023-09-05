#!/usr/bin/env bash
#!/bin/bash

php_runkit() {
    pecl shell-test runkit7 || sudo pecl install runkit7-alpha

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

php_runkit
