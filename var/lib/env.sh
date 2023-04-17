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
                echo ${!protocol}
            fi
        fi

        unset address tcp udp
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

--test() {
    local vm_id=$(--host:fullname)
    [[ -n $1 ]] && vm_id=$1
    --curl:get $BASE_URL/etc/portforward/$vm_id?$RANDOM
}

--sys:env:sync() {
    # new
    --sys:env:sync_ domains sshdconfig

    # old
    --sys:env:sync_ portforward tunel csf dhcp
}

--sys:env:sync_() {
    local _csf_config=0
    local vm_id=$(--host:fullname)
    for param in $@; do
        sudo touch $ETC_PATH/$param

        _new=$(--curl:get $BASE_URL/etc/$param/$vm_id?$RANDOM)
        _old=$(cat $ETC_PATH/$param)
        [[ -z $_new ]] && continue
        [[ $_old == $_new ]] && continue

        echo "$_new" | sudo tee $ETC_PATH/$param >/dev/null

        case $param in

        csf)
            --csf:regex
            _csf_config=1
            ;;

        portforward)
            _csf_config=1
            ;;

        domains)
            _csf_config=1
            ;;

        dhcp)
            --sys:dhcp:config
            ;;

        sshdconfig)
            _sys:env:sshdconfig
            ;;

        *) ;;
        esac

        unset _new _old
    done
    [[ $_csf_config == 1 ]] && --csf:config
}

_sys:env:send() {
    return 0
    # --sys:env:sync
}

_sys:env:sshdconfig() {
    local user=$1
    [[ -z $user ]] && user=$(whoami)

    local match="########## DUCTN ssh config ##########"
    local file=/home/$user/.ssh/config
    local match_index=$(grep "$match" $file | wc -l)

    sudo touch $file
    if [[ $match_index == 0 ]]; then
        echo $match | sudo tee -a $file >/dev/null
        echo $match | sudo tee -a $file >/dev/null
    elif [[ $match_index == 1 ]]; then
        sudo sed -i "/$match/a\\$match" $file
    fi

    sshdconfig=$(cat $ETC_PATH/sshdconfig)

    cat <<EOF | sudo sed -i -e "/$match/{:a;N;/\n$match$/!ba;r /dev/stdin" -e ";d}" $file
$match

$sshdconfig

$match
EOF

    # cat $file
    # echo $sshdconfig
}

--sys:env:sshdconfig() {
    _sys:env:sshdconfig
}
