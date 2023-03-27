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

--sys:env:dhcp() {
    dhcp_name=$1
    dhcp_type="vm_$2"
    dhcp_types=("vm_mac" "vm_address")

    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        line=$(echo $line | xargs)
        readarray -d ' ' -t strarr <<<"$line"
        # declare -p strarr

        vm_name=${strarr[0]}
        vm_mac=${strarr[1]}
        vm_address=${strarr[2]}

        if [[ -z $dhcp_name ]]; then
            echo $vm_name | xargs
        elif [[ $dhcp_name == $vm_name ]]; then
            if [[ " ${dhcp_types[*]} " =~ " ${dhcp_type} " ]]; then
                echo -e "${!dhcp_type}" | xargs
            fi
        fi

        unset vm_name vm_mac vm_address
    done <$ETC_PATH/dhcp

    unset dhcp_name dhcp_type dhcp_types
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

            if [[ $param == "dhcp" ]]; then
                [[ ! $_old == $_new ]] && --sys:dhcp:config
            fi
            unset _new _old
        done
    }

    _sync domains portforward tunel csf dhcp
}
