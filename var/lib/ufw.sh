#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:ufw")
--sys:ufw() {
    if [ "$(--sys:ufw:is_active)" == "active" ]; then
        --sys:ufw:cleanup
        --sys:ufw:allow
        # --sys:hosts
    fi
}

_DUCTN_COMMANDS+=("sys:ufw:cleanup")
--sys:ufw:cleanup() {
    --ufw:cleanup
}

_DUCTN_COMMANDS+=("sys:ufw:allow")
--sys:ufw:allow() {
    for domain in $(--sys:env:domains); do
        # echo $domain
        --sys:ufw:_allow $domain
    done
}

_DUCTN_COMMANDS+=("sys:ufw:is_active")
--sys:ufw:is_active() {
    if [ "$(--sys:service:isactive ufw)" == "active" ]; then
        echo active
    else
        if [[ $(--sys:ufw:is_exist) -eq 1 ]]; then
            sudo ufw status | grep 'inactive' >/dev/null 2>&1
            [ $? = 0 ] && echo inactive || echo active
        else
            echo inactive
        fi
    fi

    # sudo ufw status | grep 'active' >/dev/null 2>&1
    # if [ $? = 0 ]; then
    #     echo active
    # else
    #     echo deactive
    # fi
}

--sys:hosts() {
    # --hosts:add $(--host:address dxvnmg15.diepxuan.com) mg15
    # --hosts:add $(--host:address dx3.diepxuan.com) dx3

    --do_no_thing
}

--sys:ufw:_allow() {
    # sudo ufw allow proto tcp from "$(--host:address $@)" to any port 1433
    _IP=$(--host:address $@)
    if [ ! "$_IP" = "127.0.0.1" ] && [ $(--sys:ufw:is_exist $_IP) = 0 ]; then
        sudo ufw allow from "$(--host:address $@)"
    fi
}

--sys:ufw:is_exist() {
    [ ! -x "$(command -v ufw)" ] && echo 0 || echo 1
}

_DUCTN_COMMANDS+=("ufw:cleanup")
--ufw:cleanup() {
    TYPE=$1
    DDNS_IPS=()

    for domain in $(--sys:env:domains); do
        IP="$(--host:address $domain)"
        DDNS_IPS+=($IP)
    done

    sudo ufw status numbered | sed -n '/Anywhere[[:space:]]\+ALLOW IN[[:space:]]\+/p' | while read line; do
        line="$(echo "$line" | sed -r 's/[[:space:]*[0-9]+][[:space:]]Anywhere[[:space:]]+ALLOW IN[[:space:]]+//g')"
        line="$(echo "$line" | sed -r 's/\/tcp//g')"

        if [[ " ${DDNS_IPS[*]} " =~ " ${line} " ]]; then
            [[ $TYPE =~ "cmd" ]] && --echo "Exist $line"
        else
            # sudo ufw delete allow proto tcp from "$line"
            sudo ufw delete allow from "$line"
            [[ $TYPE =~ "cmd" ]] && --echo "Remove $line"
        fi

    done
}

_DUCTN_COMMANDS+=("ufw:profile:mssql")
--ufw:profile:mssql() {
    [[ -f /etc/ufw/applications.d/mssql.ufw.profile ]] || echo -e "$ufw_profile_mssql" | sudo tee /etc/ufw/applications.d/mssql.ufw.profile >/dev/null
}

ufw_profile_mssql="[SQLServer]
title=SQLServer
description=SQLServer server.
ports=1433/tcp|1434/udp
"
#!/usr/bin/env bash
#!/bin/bash

# options_found=0
# while getopts ":u" opt; do
#     options_found=1
#     case $opt in
#     u)
#         username=$OPTARG
#         echo "username = $OPTARG"
#         ;;
#     esac
# done

# if ((!options_found)); then
#     echo "no options found"
# fi
