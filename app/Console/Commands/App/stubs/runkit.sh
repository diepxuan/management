#!/usr/bin/env bash
#!/bin/bash

php_runkit() {
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
}

php_runkit
