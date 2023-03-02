#!/usr/bin/env bash
#!/bin/bash

. $_BASHDIR/environment.sh

--init() {
    mkdir -p $DIRTMP
    sudo chmod 777 -R $DIRTMP

    --sys:env
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
}

--install() {
    --sys:apt:install jq
    # --sys:apt:install resolvconf

    --sys:service:install
}

--import
--init

--install