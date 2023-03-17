#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("ufw:iptables")
--ufw:iptables() {
    iptables_path=$(_iptables_path4)
    _SRV_NUM=$(--host:name)
    _SRV_NUM=${_SRV_NUM:3}
    while IFS= read -r rule; do
        if [[ -n $rule ]]; then
            rule=${rule//'.pve.'/".$_SRV_NUM."}
            check=$rule
            check=${check//'-A '/'-C '}
            check=${check//'-I '/'-C '}
            check=${check//'-N '/'-C '}
            sudo $iptables_path "$check" 2>/dev/null
            [[ $? == 1 ]] && sudo $iptables_path $rule
        fi
    done < <(_rules)
}

_rules() {
    if [ ! $(--host:is_server) == 1 ] && [ ! $(--host:is_vpn_server) == 1 ]; then
        return 0
    fi

    _SRV_NUM=$(--host:name)
    _SRV_NUM=${_SRV_NUM:3}

    function _chain_exists() {
        [ $# -lt 1 -o $# -gt 2 ] && {
            echo "Usage: chain_exists <chain_name> [table]" >&2
            return 1
        }
        local chain_name="$1"
        shift
        [ $# -eq 1 ] && local table="--table $1"
        sudo ${iptables_path} $table -n --list "$chain_name" >/dev/null 2>&1
    }

    function _rule() {
        _rule=$*
        _rule=${_rule//'.pve.'/".$_SRV_NUM."}
        echo $_rule
    }

    # if $(_chain_exists ufw-before-input); then
    #     while IFS= read -r rule; do
    #         [[ -n $rule ]] && _rule $rule
    #     done < <(--ufw:geoip:allowCloudflare)
    # else
    #     while IFS= read -r rule; do
    #         [[ -n $rule ]] && _rule ${rule//'ufw-before-input'/'INPUT'}
    #     done < <(--ufw:geoip:allowCloudflare)
    # fi

    ######### VPN Firewall Site-to-Site #########
    if [[ $(--host:is_server) == 1 ]]; then
        # Allow internet access for vm clients
        _rule "-t nat -A POSTROUTING -s '10.0.pve.0/24' -o vmbr0 -j MASQUERADE"
        _rule "-t raw -I PREROUTING -i fwbr+ -j CT --zone 1"
        [[ "$(ip tuntap show | grep tun0)" != "" ]] && _rule "-t nat -A POSTROUTING -s '10.0.pve.0/24' -o tun0 -j MASQUERADE"

        # NAT port to vm client
        for nat in $(--sys:env:nat); do
            port=${nat%:*}    # remove suffix starting with "_"
            address=${nat#*:} # remove prefix ending in "_"

            [[ -n $port ]] && [[ -n $address ]] && _rule "-t nat -A PREROUTING -p TCP --dport $port -j DNAT --to-destination $address"
        done
    fi

    ######### VPN Firewall DMZ to Pve server #########
    if [ $(--host:is_vpn_server) == 1 ]; then
        echo "$(_dmz_rules)"
    fi
}

_DUCTN_COMMANDS+=("ufw:iptables:uninstall")
--ufw:iptables:uninstall() {
    sudo systemctl stop ductn-iptables 2>/dev/null
    sudo systemctl disable ductn-iptables 2>/dev/null
    sudo rm -rf /usr/lib/systemd/system/ductn-iptables.service 2>/dev/null
    sudo systemctl daemon-reload 2>/dev/null
}

_iptables_path4() {
    # Create a service to set up persistent iptables rules
    iptables_path=$(sudo su -c "command -v iptables")
    # nf_tables is not available as standard in OVZ kernels. So use iptables-legacy
    # if we are in OVZ, with a nf_tables backend and iptables-legacy is available.
    if [[ $(systemd-detect-virt) == "openvz" ]] && readlink -f "$(sudo su -c "command -v iptables")" | grep -q "nft" && hash iptables-legacy 2>/dev/null; then
        iptables_path=$(sudo su -c "command -v iptables-legacy")
    fi
    echo "$iptables_path"
}

_iptables_path6() {
    ip6tables_path=$(sudo su -c "command -v ip6tables")
    if [[ $(systemd-detect-virt) == "openvz" ]] && readlink -f "$(sudo su -c "command -v iptables")" | grep -q "nft" && hash iptables-legacy 2>/dev/null; then
        ip6tables_path=$(sudo su -c "command -v ip6tables-legacy")
    fi
    echo $ip6tables_path
}

_dmz_rules() {
    DMZ_RULES=""

    INET_IP="$(--ip:wan)"
    INET_IFACE="$(route | grep '^default' | head -1 | grep -o '[^ ]*$')"

    LAN_IP="$(--ip:local)"
    # LAN_IFACE="tun0"

    DMZ_IP="10.8.0.2"
    DMZ_IFACE="tun0"

    LO_IFACE="lo"
    LO_IP="127.0.0.1"

    if [ ! "$(--sys:service:isactive ufw)" == "active" ]; then
        # echo "-X bad_tcp_packets"
        echo "-N bad_tcp_packets"
        echo "-N allowed"
        echo "-N icmp_packets"

        echo "-A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j LOG --log-prefix \"New not syn:\""
        echo "-A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j DROP"

        echo "-A bad_tcp_packets -i $INET_IFACE -s 192.168.0.0/16 -j DROP"
        echo "-A bad_tcp_packets -i $INET_IFACE -s 10.0.0.0/8 -j DROP"
        echo "-A bad_tcp_packets -i $INET_IFACE -s 172.16.0.0/12 -j DROP"
        echo "-A bad_tcp_packets -i $INET_IFACE -s $INET_IP -j DROP"

        echo "-A allowed -p TCP --syn -j ACCEPT"
        echo "-A allowed -p TCP -m state --state ESTABLISHED,RELATED -j ACCEPT"
        echo "-A allowed -p TCP -j DROP"

        echo "-A icmp_packets -p ICMP -s 0/0 --icmp-type 0 -j ACCEPT"
        echo "-A icmp_packets -p ICMP -s 0/0 --icmp-type 3 -j ACCEPT"
        echo "-A icmp_packets -p ICMP -s 0/0 --icmp-type 5 -j ACCEPT"
        echo "-A icmp_packets -p ICMP -s 0/0 --icmp-type 8 -j ACCEPT"
        echo "-A icmp_packets -p ICMP -s 0/0 --icmp-type 11 -j ACCEPT"

        echo "-A INPUT -p tcp -j bad_tcp_packets"
        echo "-A INPUT -p ICMP -i $INET_IFACE -j icmp_packets"
        echo "-A INPUT -p ALL -i $DMZ_IFACE -d $DMZ_IP -j ACCEPT"
        # echo "-A INPUT -p ALL -i $LAN_IFACE -d $LAN_IP -j ACCEPT"
        # echo "-A INPUT -p ALL -i $LAN_IFACE -d $LAN_BROADCAST_ADDRESS -j ACCEPT"
        echo "-A INPUT -p ALL -i $LO_IFACE -s $LO_IP -j ACCEPT"
        echo "-A INPUT -p ALL -i $LO_IFACE -s $LAN_IP -j ACCEPT"
        echo "-A INPUT -p ALL -i $LO_IFACE -s $INET_IP -j ACCEPT"
        echo "-A INPUT -p ALL -d $INET_IP -m state --state ESTABLISHED,RELATED -j ACCEPT"
        echo "-A INPUT -m limit --limit 3/minute --limit-burst 3 -j LOG --log-prefix \"IPT INPUT packet died: \""

        echo "-A FORWARD -p tcp -j bad_tcp_packets"
        echo "-A FORWARD -i $DMZ_IFACE -o $INET_IFACE -j ACCEPT"
        echo "-A FORWARD -i $INET_IFACE -o $DMZ_IFACE -m state --state ESTABLISHED,RELATED -j ACCEPT"
        # echo "-A FORWARD -i $LAN_IFACE -o $DMZ_IFACE -j ACCEPT"
        # echo "-A FORWARD -i $DMZ_IFACE -o $LAN_IFACE -m state --state ESTABLISHED,RELATED -j ACCEPT"
        echo "-A FORWARD -m limit --limit 3/minute --limit-burst 3 -j LOG --log-prefix \"IPT FORWARD packet died: \""

        echo "-A OUTPUT -p tcp -j bad_tcp_packets"
        echo "-A OUTPUT -m limit --limit 3/minute --limit-burst 3 -j LOG --log-prefix \"IPT OUTPUT packet died: \""
    fi

    # Enable simple IP Forwarding and Network Address Translation
    echo "-t nat -A POSTROUTING -o $INET_IFACE -j SNAT --to-source $INET_IP"

    echo "-t nat -A PREROUTING -p TCP -i $INET_IFACE -d $INET_IP --dport 53 -j DNAT --to-destination $DMZ_IP"
    echo "-t nat -A PREROUTING -p UDP -i $INET_IFACE -d $INET_IP --dport 53 -j DNAT --to-destination $DMZ_IP"

    # NAT port to vm client
    for nat in $(--sys:env:nat); do
        port=${nat%:*} # remove suffix starting with "_"
        [[ -n $port ]] && echo "-t nat -A PREROUTING -p TCP -i $INET_IFACE -d $INET_IP --dport $port -j DNAT --to-destination $DMZ_IP"
    done
}
