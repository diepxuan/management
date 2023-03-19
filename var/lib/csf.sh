#!/usr/bin/env bash
#!/bin/bash

--csf:install() {
    --ufw:geoip:uninstall
    --ufw:fail2ban:uninstall
    --sys:ufw:disable

    --sys:apt:install libwww-perl perl

    curl http://download.configserver.com/csf.tgz -o /tmp/ductn/csf.tgz
    tar -xzf /tmp/ductn/csf.tgz -C /tmp/ductn

    cd /tmp/ductn/csf && sudo sh install.sh
}

--csf:config() {
    while IFS= read -r cnf; do
        [[ -z $cnf ]] && continue
        param=${cnf% = *}
        value=${cnf#* = }
        value=${value//\"/}
        sudo sed -i "s/$param = .*/$param = \"$value\"/" /etc/csf/csf.conf
    done < <(--sys:env:csf)

    [[ -f /etc/csf/csfpost.sh ]] || sudo touch /etc/csf/csfpost.sh
    echo "$(_csf_rules)" | sudo tee /etc/csf/csfpost.sh >/dev/null

    sudo csf -r
}

_csf_rules() {
    # if [[ ! $(--host:is_vpn_server) == 1 ]]; then
    # return 0
    # fi

    DMZ_RULES=""

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
        echo "iptables -t nat -A POSTROUTING -o $INET_IFACE -j MASQUERADE"
        echo "iptables -t raw -I PREROUTING -i fwbr+ -j CT --zone 1"

        echo "iptables -A INPUT -i tun+ -j ACCEPT"
        echo "iptables -A FORWARD -i tun+ -j ACCEPT"
        [[ "$(ip tuntap show | grep tun0)" != "" ]] && echo "iptables -A FORWARD -o tun0 -j ACCEPT"

        echo "iptables -A FORWARD -i tun+ -o $INET_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT"
        echo "iptables -A FORWARD -i $INET_IFACE -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT"

        for nat in $(--sys:env:nat); do
            port=${nat%:*}
            [[ -n $port ]] && [[ -n $address ]] && echo "iptables -t nat -A PREROUTING -p TCP --dport $port -j DNAT --to-destination $DMZ_IP"
        done
    fi

    if [[ $(--host:is_server) == 1 ]]; then
        echo "iptables -t nat -A POSTROUTING -o $INET_IFACE -j MASQUERADE"
        echo "iptables -t raw -I PREROUTING -i fwbr+ -j CT --zone 1"

        echo "iptables -A INPUT -i tun+ -j ACCEPT"
        echo "iptables -A FORWARD -i tun+ -j ACCEPT"
        [[ "$(ip tuntap show | grep tun0)" != "" ]] && echo "iptables -A FORWARD -o tun0 -j ACCEPT"

        echo "iptables -t nat -A POSTROUTING -s '10.0.$SRV_NUM.0/24' -o vmbr0 -j MASQUERADE"
        [[ "$(ip tuntap show | grep tun0)" != "" ]] && echo "iptables -t nat -A POSTROUTING -s '10.0.$SRV_NUM.0/24' -o tun0 -j MASQUERADE"

        echo "iptables -A FORWARD -i tun+ -o $INET_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT"
        echo "iptables -A FORWARD -i $INET_IFACE -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT"
        echo "iptables -A FORWARD -i tun+ -o $LAN_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT"
        echo "iptables -A FORWARD -i $LAN_IFACE -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT"

        for nat in $(--sys:env:nat); do
            port=${nat%:*}
            address=${nat#*:}
            address=${address//'.pve.'/".$SRV_NUM."}

            [[ -n $port ]] && [[ -n $address ]] && echo "iptables -t nat -A PREROUTING -p TCP --dport $port -j DNAT --to-destination $address"
        done
    fi

    # # Enable simple IP Forwarding and Network Address Translation
    # echo "-t nat -A POSTROUTING -o $INET_IFACE -j SNAT --to-source $INET_IP"

    # echo "-t nat -A PREROUTING -p TCP -i $INET_IFACE -d $INET_IP --dport 53 -j DNAT --to-destination $DMZ_IP"
    # echo "-t nat -A PREROUTING -p UDP -i $INET_IFACE -d $INET_IP --dport 53 -j DNAT --to-destination $DMZ_IP"

    # # NAT port to vm client
    # for nat in $(--sys:env:nat); do
    #     port=${nat%:*} # remove suffix starting with "_"
    #     [[ -n $port ]] && echo "-t nat -A PREROUTING -p TCP -i $INET_IFACE -d $INET_IP --dport $port -j DNAT --to-destination $DMZ_IP"
    # done
}
