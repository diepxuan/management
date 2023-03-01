#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("ufw:cleanup")
--ufw:cleanup() {
    TYPE=$1

    DDNS_IPS=()
    for domain in "${DDNS_DOMAINS[@]}"; do
        IP="$(--host:address $domain)"
        DDNS_IPS+=($IP)
    done

    sudo ufw status numbered | sed -n '/Anywhere[[:space:]]\+ALLOW IN[[:space:]]\+/p' | while read line; do
        line="$(echo "$line" | sed -r 's/[[:space:]*[0-9]+][[:space:]]Anywhere[[:space:]]+ALLOW IN[[:space:]]+//g')"
        line="$(echo "$line" | sed -r 's/\/tcp//g')"

        if [[ " ${DDNS_IPS[*]} " =~ " ${line} " ]]; then
            [[ $TYPE =~ "cmd" ]] && echo "Exist $line"
        else
            # sudo ufw delete allow proto tcp from "$line"
            sudo ufw delete allow from "$line"
            [[ $TYPE =~ "cmd" ]] && echo "Remove $line"
        fi

    done
}

_DUCTN_COMMANDS+=("ufw:profile:mssql")
--ufw:profile:mssql() {
    echo $ufw_profile_mssql | sudo tee /etc/ufw/applications.d/mssql.ufw.profile
}

ufw_profile_mssql="[SQLServer]
title=SQLServer
description=SQLServer server.
ports=1433/tcp|1434/udp"
