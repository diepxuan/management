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

--sys:hosts() {
    # --hosts:add $(--host:address dxvnmg15.diepxuan.com) mg15
    # --hosts:add $(--host:address dx3.diepxuan.com) dx3

    --do_no_thing
}

_DUCTN_COMMANDS+=("sys:ufw:cleanup")
--sys:ufw:cleanup() {
    --ufw:cleanup
}

--sys:ufw:_allow() {
    # if [ "$(whoami)" = "ductn" ]; then
    # sudo ufw allow proto tcp from "$(--host:address $@)" to any port 1433
    sudo ufw allow from "$(--host:address $@)"
    # fi
}

_DUCTN_COMMANDS+=("sys:ufw:allow")
--sys:ufw:allow() {
    for domain in "${DDNS_DOMAINS[@]}"; do
        # echo $domain
        --sys:ufw:_allow $domain
    done
}

_DUCTN_COMMANDS+=("sys:ufw:is_active")
--sys:ufw:is_active() {
    if [ "$(--sys:service:isactive ufw)" == "active" ]; then
        echo active
    else
        echo inactive
    fi

    # sudo ufw status | grep 'active' >/dev/null 2>&1
    # if [ $? = 0 ]; then
    #     echo active
    # else
    #     echo deactive
    # fi
}
