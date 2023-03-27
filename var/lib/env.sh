#!/usr/bin/env bash
#!/bin/bash

--sys:env() {
    echo -e "${!@}" | xargs
}

--sys:env:domains() {
    cat $ETC_PATH/domains
}

--sys:env:nat() {
    serial=$(--host:serial)

    ip=$1
    [[ -z $ip ]] && ip=ip

    protocol=$2
    [[ -z $protocol ]] && protocol=tcp
    protocols=("tcp" "udp")

    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        readarray -d : -t strarr <<<"$line"

        address=${strarr[0]}
        address=${address//'.pve.'/".$serial."}
        tcp=${strarr[1]}
        udp=${strarr[2]}

        if [[ $ip == "ip" ]]; then
            echo "$address" | xargs
        elif [[ $ip == "$address" ]]; then
            if [[ " ${protocols[*]} " =~ " ${protocol} " ]]; then
                echo -e "${!protocol}" | xargs
            fi
        fi

        unset address tcp udp all
    done <$ETC_PATH/portforward

    unset ip protocol protocols serial

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
            _new=$(curl -o - https://diepxuan.github.io/ppa/etc/$param?$RANDOM 2>/dev/null)
            _old=$(cat $ETC_PATH/$param)

            [[ ! $_old == $_new ]] && echo "$_new" | sudo tee $ETC_PATH/$param >/dev/null

            if [[ $param == "csf" ]]; then
                --csf:regex
                [[ ! $_old == $_new ]] && --csf:config
            fi
            unset _new _old
        done
    }

    _sync domains portforward tunel csf
}
