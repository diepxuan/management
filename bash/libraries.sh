#!/usr/bin/env bash
#!/bin/bash

--init() {
    mkdir -p /tmp/ductn
    sudo chmod 777 -R /tmp/ductn

    --import
    --install
}

--import() {
    if [ -d $_BINDIR ]; then
        for f in $_BINDIR/*.sh; do
            if [[ -f $f ]]; then
                source $f
                # test -x $f && source $f
                # echo $f
            fi
        done
    fi

    # Load default environment
    . $_BASHDIR/environment.sh
}

--install() {
    --sys:apt:install jq
    --sys:apt:install net-tools
    # --sys:apt:install resolvconf

    --sys:service:install
}

--init
