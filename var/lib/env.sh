#!/usr/bin/env bash
#!/bin/bash

--sys:env() {
    echo -e $* | xargs
}

--sys:env:domains() {
    cat $ETC_PATH/domains
}

--sys:env:nat() {
    cat $ETC_PATH/nat
}

--sys:env:vpn() {
    cat $ETC_PATH/tunel
}

--sys:env:csf() {
    cat $ETC_PATH/csf
}

--sys:env:sync() {
    _sync() {

        for param in $@; do
            _new=$(curl -H 'Cache-Control: no-cache, no-store' -H 'Pragma: no-cache' -o - https://diepxuan.github.io/ppa/etc/$param?$RANDOM 2>/dev/null)
            _old=$(cat $ETC_PATH/$param)

            [[ ! $_old == $_new ]] && echo "$_new" | sudo tee $ETC_PATH/$param >/dev/null

            if [[ $param == "csf" ]]; then
                --csf:regex
                [[ ! $_old == $_new ]] && --csf:config
            fi
        done
    }

    _sync domains nat tunel csf
}
