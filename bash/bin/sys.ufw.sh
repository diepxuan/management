#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:ufw")
--sys:ufw() {
    --sys:ufw:cleanup
    --sys:ufw:allow
    # --sys:hosts
}

--sys:hosts() {
    # --hosts:add $(--ddns:getip dxvnmg15.diepxuan.com) mg15
    # --hosts:add $(--ddns:getip dx3.diepxuan.com) dx3

    --do_no_thing
}

_DUCTN_COMMANDS+=("sys:ufw:cleanup")
--sys:ufw:cleanup() {
    --ufw:cleanup
}

--sys:ufw:_allow() {
    if [ "$(whoami)" = "ductn" ]; then
        # sudo ufw allow proto tcp from "$(--ddns:getip $@)" to any port 1433
        sudo ufw allow from "$(--ddns:getip $@)"
    fi
}

_DUCTN_COMMANDS+=("sys:ufw:allow")
--sys:ufw:allow() {
    for domain in "${DDNS_DOMAINS[@]}"; do
        # echo $domain
        --sys:ufw:_allow $domain
    done
}
