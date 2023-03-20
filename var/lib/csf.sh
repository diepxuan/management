#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("csf:config")
--csf() {
    --csf:install
    --csf:config
}

_DUCTN_COMMANDS+=("csf:install")
--csf:install() {
    --sys:ufw:disable

    curl http://download.configserver.com/csf.tgz -o /tmp/ductn/csf.tgz
    tar -xzf /tmp/ductn/csf.tgz -C /tmp/ductn

    cd /tmp/ductn/csf && sudo sh install.sh

    [[ -n $(command -v iptables) ]] && [[ $(which iptables) != /sbin/iptables ]] && [[ ! -f /sbin/iptables ]] && sudo ln $(which iptables) /sbin/iptables
    [[ -n $(command -v iptables-save) ]] && [[ $(which iptables-save) != /sbin/iptables-save ]] && [[ ! -f /sbin/iptables-save ]] && sudo ln $(which iptables-save) /sbin/iptables-save
    [[ -n $(command -v iptables-restore) ]] && [[ $(which iptables-restore) != /sbin/iptables-restore ]] && [[ ! -f /sbin/iptables-restore ]] && sudo ln $(which iptables-restore) /sbin/iptables-restore
}

_DUCTN_COMMANDS+=("csf:config")
--csf:config() {
    while IFS= read -r cnf; do
        [[ -z $cnf ]] && continue
        param=${cnf% = *}
        value=${cnf#* = }
        value=${value//\"/}
        --csf:config:set $param $value
    done < <(--sys:env:csf)

    [[ -f /etc/csf/csfpost.sh ]] || sudo touch /etc/csf/csfpost.sh
    echo "$(_csf_rules)" | sudo tee /etc/csf/csfpost.sh

    # Restart firewall rules (csf) and then restart lfd daemon
    sudo csf -ra
}

_DUCTN_COMMANDS+=("csf:config:set")
--csf:config:set() {
    param=$1
    value=$2
    sudo sed -i "s/$param = .*/$param = \"$value\"/" /etc/csf/csf.conf
}

_csf_rules() {
    INET_IP="$(--ip:wan)"
    INET_IFACE="$(sudo route | grep '^default' | head -1 | grep -o '[^ ]*$')"

    LAN_IP="$(--ip:local)"
    LAN_IFACE="vmbr1"

    DMZ_IP="10.8.0.2"
    DMZ_IFACE="tun0"

    LO_IFACE="lo"
    LO_IP="127.0.0.1"

    SRV_NUM=$(--host:name)
    SRV_NUM=${SRV_NUM:3}

    if [[ $(--host:is_vpn_server) == 1 ]]; then
        echo "iptables -t raw -I PREROUTING -i fwbr+ -j CT --zone 1"
        echo "iptables -t nat -A POSTROUTING -o $INET_IFACE -j MASQUERADE"

        if [[ "$(ip tuntap show | grep tun0)" != "" ]]; then
            echo "iptables -A INPUT -i tun+ -j ACCEPT"
            echo "iptables -A FORWARD -i tun+ -j ACCEPT"
            echo "iptables -A FORWARD -o tun0 -j ACCEPT"
        fi

        echo "iptables -A FORWARD -i tun+ -o $INET_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT"
        echo "iptables -A FORWARD -i $INET_IFACE -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT"

        for nat in $(--sys:env:nat); do
            port=${nat%:*}
            [[ -n $port ]] && echo "iptables -t nat -A PREROUTING -p TCP --dport $port -j DNAT --to-destination $DMZ_IP"
        done
    fi

    if [[ $(--host:is_server) == 1 ]]; then
        echo "iptables -t raw -I PREROUTING -i fwbr+ -j CT --zone 1"

        # echo "iptables -t nat -A POSTROUTING -s 10.0.$SRV_NUM.0/24 -o $INET_IFACE -j MASQUERADE"
        echo "iptables -t nat -A POSTROUTING -o $INET_IFACE -j MASQUERADE"
        echo "iptables -A INPUT -i $LAN_IFACE -j ACCEPT"
        echo "iptables -A FORWARD -i $LAN_IFACE -j ACCEPT"
        echo "iptables -A FORWARD -o $LAN_IFACE -j ACCEPT"

        echo "iptables -A FORWARD -i $INET_IFACE -o $LAN_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT"
        echo "iptables -A FORWARD -i $LAN_IFACE -o $INET_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT"

        if [[ "$(ip tuntap show | grep tun0)" != "" ]]; then
            # echo "iptables -t nat -A POSTROUTING -s 10.0.$SRV_NUM.0/24 -o tun0 -j MASQUERADE"
            echo "iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE"
            echo "iptables -A INPUT -i tun+ -j ACCEPT"
            echo "iptables -A FORWARD -i tun+ -j ACCEPT"
            echo "iptables -A FORWARD -o tun0 -j ACCEPT"

            echo "iptables -A FORWARD -i tun+ -o $INET_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT"
            echo "iptables -A FORWARD -i $INET_IFACE -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT"
            echo "iptables -A FORWARD -i tun+ -o $LAN_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT"
            echo "iptables -A FORWARD -i $LAN_IFACE -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT"
        fi

        for nat in $(--sys:env:nat); do
            port=${nat%:*}
            address=${nat#*:}
            address=${address//'.pve.'/".$SRV_NUM."}

            [[ -n $port ]] && [[ -n $address ]] && echo "iptables -t nat -A PREROUTING -p TCP --dport $port -j DNAT --to-destination $address"
        done
    fi

    # # Enable simple IP Forwarding and Network Address Translation
    # echo "-t nat -A POSTROUTING -o $INET_IFACE -j SNAT --to-source $INET_IP"
}
