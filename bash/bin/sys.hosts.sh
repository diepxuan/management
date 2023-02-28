#!/usr/bin/env bash
#!/bin/bash

# sed -i 's/var=.*/var=new_value/' file_name

--sys:hosts:add() {
    IP=$1
    HOSTNAME=$2

    HOSTS_LINE="$IP\t$HOSTNAME"

    if [[ ! "$(--ddns:getip $HOSTNAME)" =~ "$IP" ]]; then
        if [[ ! -n $(grep -P "$IP[[:space:]]$HOSTNAME" $ETC_HOSTS) ]]; then
            sudo sed -i".bak" "/$HOSTNAME/d" ${ETC_HOSTS}
        fi
        sudo -- sh -c -e "echo '$HOSTS_LINE' >> /etc/hosts"
    fi

    [[ -n $(grep -P "$IP[[:space:]]$HOSTNAME" $ETC_HOSTS) ]] && echo ">> Hosts added: $(grep $HOSTNAME $ETC_HOSTS)" || echo "Failed to Add $HOSTNAME, Try again!"
}

--sys:hosts:remove() {
    IP=$1
    HOSTNAME=$2

    sudo sed -i".bak" "/$HOSTNAME/d" ${ETC_HOSTS}

    [[ -n "$(grep $HOSTNAME /etc/hosts)" ]] && echo ">> Hosts removed: $HOSTNAME" || echo "$HOSTNAME was not found!"
}

--sys:hosts:domain() {
    IP=$(--ip:wan)
    HOSTNAME="$(--host:fullname) $(--host:name)"
    HOSTS_LINE="$IP\\t$HOSTNAME"
    echo -e $HOSTS_LINE
}

--sys:hosts:update() {
    sed -i 's/var=.*/var=new_value/' ${ETC_HOSTS}
}
