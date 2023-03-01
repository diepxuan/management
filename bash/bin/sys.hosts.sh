#!/usr/bin/env bash
#!/bin/bash

# sed -i 's/var=.*/var=new_value/' file_name

_DUCTN_COMMANDS+=("sys:hosts:add")
--sys:hosts:add() {
    IP=$1
    HOSTNAME=$2

    HOSTS_LINE="$IP\t$HOSTNAME"

    if [[ ! "$(--host:address $HOSTNAME)" =~ "$IP" ]]; then
        if [[ ! -n $(grep -P "$IP[[:space:]]$HOSTNAME" $ETC_HOSTS) ]]; then
            sudo sed -i".bak" "/$HOSTNAME/d" ${ETC_HOSTS}
        fi
        sudo -- sh -c -e "echo '$HOSTS_LINE' >> /etc/hosts"
    fi

    [[ -n $(grep -P "$IP[[:space:]]$HOSTNAME" $ETC_HOSTS) ]] && echo ">> Hosts added: $(grep $HOSTNAME $ETC_HOSTS)" || echo "Failed to Add $HOSTNAME, Try again!"
}

_DUCTN_COMMANDS+=("sys:hosts:remove")
--sys:hosts:remove() {
    IP=$1
    HOSTNAME=$2

    sudo sed -i".bak" "/$HOSTNAME/d" ${ETC_HOSTS}

    [[ -n "$(grep $HOSTNAME /etc/hosts)" ]] && echo ">> Hosts removed: $HOSTNAME" || echo "$HOSTNAME was not found!"
}

_DUCTN_COMMANDS+=("sys:hosts:domain")
--sys:hosts:domain() {
    IP=$(--ip:wan)
    HOSTNAME="$(--host:fullname) $(--host:name)"
    HOSTS_LINE="$IP\\t$HOSTNAME"
    echo -e $HOSTS_LINE
}

_DUCTN_COMMANDS+=("sys:hosts:update")
--sys:hosts:update() {
    sed -i 's/var=.*/var=new_value/' ${ETC_HOSTS}
}
