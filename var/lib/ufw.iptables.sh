#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("ufw:iptables")
--ufw:iptables() {
    if [ ! $(--host:is_server) == 1 ] && [ ! $(--host:is_vpn_server) == 1 ]; then
        sudo systemctl stop ductn-iptables 2>/dev/null
        sudo systemctl disable ductn-iptables 2>/dev/null
        sudo rm -rf /usr/lib/systemd/system/ductn-iptables.service 2>/dev/null
        sudo systemctl daemon-reload 2>/dev/null
        return 0
    fi
    iptables_path=$(--ufw:iptables:path4)
    ip6tables_path=$(--ufw:iptables:path6)
    iptables_rules_HEAD=""
    iptables_rules_FOOT=""

    _SRV_NUM=$(--host:name)
    _SRV_NUM=${_SRV_NUM:3}

    function _rule_out() {
        # echo -e "$@"
        while IFS= read -r _rule; do
            _rule=${_rule//'.pve.'/".$_SRV_NUM."}

            # [[ -n $_rule ]] && echo -e "ExecStart=$iptables_path\t$_rule" | sudo tee -a /usr/lib/systemd/system/ductn-iptables.service
            [[ -n $_rule ]] && iptables_rules_HEAD="$iptables_rules_HEAD\nExecStart=$iptables_path $_rule"

            _rule=${_rule//'-A '/'-D '}
            _rule=${_rule//'-I '/'-D '}
            _rule=${_rule//'-N '/'-X '}

            # [[ -n $_rule ]] && echo -e "ExecStop=$iptables_path\t$_rule" | sudo tee -a /usr/lib/systemd/system/ductn-iptables.service
            [[ -n $_rule ]] && iptables_rules_FOOT="ExecStop=$iptables_path $_rule\n$iptables_rules_FOOT"
        done <<<"$@"
    }

    function _rule_nat() {
        _ip=$1
        _port=$2
        [[ -z "$_port" ]] && _port="80"
        [[ ! -z $_ip ]] && _rule_out "-t nat -A PREROUTING -p TCP --dport $_port -j DNAT --to-destination $_ip"
    }

    ######### UFW allow Cloudflare ips #########
    _chain_exists() {
        [ $# -lt 1 -o $# -gt 2 ] && {
            echo "Usage: chain_exists <chain_name> [table]" >&2
            return 1
        }
        local chain_name="$1"
        shift
        [ $# -eq 1 ] && local table="--table $1"
        sudo ${iptables_path} $table -n --list "$chain_name" >/dev/null 2>&1
    }

    if $(_chain_exists ufw-before-input); then
        while IFS= read -r rule; do
            _rule_out $rule
        done < <(--ufw:geoip:allowCloudflare)
    else
        while IFS= read -r rule; do
            _rule_out ${rule//'ufw-before-input'/'INPUT'}
        done < <(--ufw:geoip:allowCloudflare)
    fi

    ######### VPN Firewall Site-to-Site #########
    if [[ $(--host:is_server) == 1 ]]; then
        # Allow internet access for vm clients
        _rule_out "-t nat -A POSTROUTING -s '10.0.pve.0/24' -o vmbr0 -j MASQUERADE"
        _rule_out "-t raw -I PREROUTING -i fwbr+ -j CT --zone 1"
        [[ "$(ip tuntap show | grep tun0)" != "" ]] && _rule_out "-t nat -A POSTROUTING -s '10.0.pve.0/24' -o tun0 -j MASQUERADE"

        # NAT port to vm client
        for nat in $(--sys:env:nat); do
            # IFS=':' read -r -a array <<<$nat
            # port="${array[0]}"
            # address="${array[1]}"

            # port=$(echo $nat | cut -d':' -f 1)
            # address=$(echo $nat | cut -d':' -f 2)

            port=${nat%:*}    # remove suffix starting with "_"
            address=${nat#*:} # remove prefix ending in "_"

            [[ -n $port ]] && [[ -n $address ]] && _rule_out "-t nat -A PREROUTING -p TCP --dport $port -j DNAT --to-destination $address"
        done
    fi

    ######### VPN Firewall DMZ to Pve server #########
    if [ $(--host:is_vpn_server) == 1 ]; then
        # load modules
        sudo /sbin/depmod -a
        sudo /sbin/modprobe ip_tables
        sudo /sbin/modprobe ip_conntrack
        sudo /sbin/modprobe iptable_filter
        sudo /sbin/modprobe iptable_mangle
        sudo /sbin/modprobe iptable_nat
        sudo /sbin/modprobe ipt_LOG
        sudo /sbin/modprobe ipt_limit
        sudo /sbin/modprobe ipt_state
        sudo /sbin/modprobe ipt_MASQUERADE

        _rule_out "$(_ufw:dmz)"
    fi

    echo -e "[Unit]
Description=Ductn iptables service
Before=network.target

[Service]
Type=oneshot
$iptables_rules_HEAD

$iptables_rules_FOOT
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target" | sudo tee /usr/lib/systemd/system/ductn-iptables.service

    # sudo  systemctl enable --now ductn-iptables.service
    # cat /usr/lib/systemd/system/ductn-iptables.service

    sudo systemctl stop ductn-iptables
    sudo $iptables_path -X bad_tcp_packets 2>/dev/null
    sudo $iptables_path -X allowed 2>/dev/null
    sudo $iptables_path -X icmp_packets 2>/dev/null

    sudo systemctl daemon-reload
    sudo systemctl enable ductn-iptables
    sudo systemctl restart ductn-iptables

    if [ "$(--sys:service:isactive ductn-iptables)" == "failed" ]; then
        sudo systemctl status ductn-iptables
    fi
}

--ufw:iptables:path4() {
    # Create a service to set up persistent iptables rules
    iptables_path=$(sudo su -c "command -v iptables")
    # nf_tables is not available as standard in OVZ kernels. So use iptables-legacy
    # if we are in OVZ, with a nf_tables backend and iptables-legacy is available.
    if [[ $(systemd-detect-virt) == "openvz" ]] && readlink -f "$(sudo su -c "command -v iptables")" | grep -q "nft" && hash iptables-legacy 2>/dev/null; then
        iptables_path=$(sudo su -c "command -v iptables-legacy")
    fi
    echo "$iptables_path"
}

--ufw:iptables:path6() {
    ip6tables_path=$(sudo su -c "command -v ip6tables")
    if [[ $(systemd-detect-virt) == "openvz" ]] && readlink -f "$(sudo su -c "command -v iptables")" | grep -q "nft" && hash iptables-legacy 2>/dev/null; then
        ip6tables_path=$(sudo su -c "command -v ip6tables-legacy")
    fi
    echo $ip6tables_path
}

_ufw:dmz() {
    DMZ_RULES=""

    INET_IP="$(--ip:wan)"
    INET_IFACE="$(route | grep '^default' | grep -o '[^ ]*$')"

    LAN_IP="$(--ip:local)"
    # LAN_IFACE="tun0"

    DMZ_IP="10.8.0.2"
    DMZ_IFACE="tun0"

    LO_IFACE="lo"
    LO_IP="127.0.0.1"

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

    echo "-t nat -A POSTROUTING -o $INET_IFACE -j SNAT --to-source $INET_IP"
    echo "-t nat -A PREROUTING -p TCP -i $INET_IFACE -d $INET_IP --dport 53 -j DNAT --to-destination $DMZ_IP"
    echo "-t nat -A PREROUTING -p UDP -i $INET_IFACE -d $INET_IP --dport 53 -j DNAT --to-destination $DMZ_IP"

    # NAT port to vm client
    for nat in $(--sys:env:nat); do
        port=${nat%:*} # remove suffix starting with "_"
        [[ -n $port ]] && echo "-t nat -A PREROUTING -p TCP -i $INET_IFACE -d $INET_IP --dport $port -j DNAT --to-destination $DMZ_IP"
    done

    # echo "-t nat -A PREROUTING -i $INET_IFACE -s 192.168.0.0/16 -j DROP"
    # echo "-t nat -A PREROUTING -i $INET_IFACE -s 10.0.0.0/8 -j DROP"
    # echo "-t nat -A PREROUTING -i $INET_IFACE -s 172.16.0.0/12 -j DROP"
    # echo "-t nat -A PREROUTING -i $INET_IFACE -s $INET_IP -j DROP"
}

--ufw:DMZ_example() {
    #!/bin/sh
    #
    # rc.DMZ.firewall - DMZ IP Firewall script for Linux 2.4.x and iptables
    #
    # Copyright (C) 2001  Oskar Andreasson <bluefluxATkoffeinDOTnet>
    #
    # This program is free software; you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation; version 2 of the License.
    #
    # This program is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.
    #
    # You should have received a copy of the GNU General Public License
    # along with this program or from the site that you downloaded it
    # from; if not, write to the Free Software Foundation, Inc., 59 Temple
    # Place, Suite 330, Boston, MA  02111-1307   USA
    #

    ###########################################################################
    #
    # 1. Configuration options.
    #

    #
    # 1.1 Internet Configuration.
    #

    INET_IP="194.236.50.152"
    HTTP_IP="194.236.50.153"
    DNS_IP="194.236.50.154"
    INET_IFACE="eth0"

    #
    # 1.1.1 DHCP
    #

    #
    # 1.1.2 PPPoE
    #

    #
    # 1.2 Local Area Network configuration.
    #
    # your LAN's IP range and localhost IP. /24 means to only use the first 24
    # bits of the 32 bit IP address. the same as netmask 255.255.255.0
    #

    LAN_IP="192.168.0.2"
    LAN_IFACE="eth1"

    #
    # 1.3 DMZ Configuration.
    #

    DMZ_HTTP_IP="192.168.1.2"
    DMZ_DNS_IP="192.168.1.3"
    DMZ_IP="192.168.1.1"
    DMZ_IFACE="eth2"

    #
    # 1.4 Localhost Configuration.
    #

    LO_IFACE="lo"
    LO_IP="127.0.0.1"

    #
    # 1.5 IPTables Configuration.
    #

    IPTABLES="/usr/sbin/iptables"

    #
    # 1.6 Other Configuration.
    #

    ###########################################################################
    #
    # 2. Module loading.
    #

    #
    # Needed to initially load modules
    #
    /sbin/depmod -a

    #
    # 2.1 Required modules
    #

    /sbin/modprobe ip_tables
    /sbin/modprobe ip_conntrack
    /sbin/modprobe iptable_filter
    /sbin/modprobe iptable_mangle
    /sbin/modprobe iptable_nat
    /sbin/modprobe ipt_LOG
    /sbin/modprobe ipt_limit
    /sbin/modprobe ipt_state

    #
    # 2.2 Non-Required modules
    #

    #/sbin/modprobe ipt_owner
    #/sbin/modprobe ipt_REJECT
    #/sbin/modprobe ipt_MASQUERADE
    #/sbin/modprobe ip_conntrack_ftp
    #/sbin/modprobe ip_conntrack_irc
    #/sbin/modprobe ip_nat_ftp
    #/sbin/modprobe ip_nat_irc

    ###########################################################################
    #
    # 3. /proc set up.
    #

    #
    # 3.1 Required proc configuration
    #

    echo "1" >/proc/sys/net/ipv4/ip_forward

    #
    # 3.2 Non-Required proc configuration
    #

    #echo "1" > /proc/sys/net/ipv4/conf/all/rp_filter
    #echo "1" > /proc/sys/net/ipv4/conf/all/proxy_arp
    #echo "1" > /proc/sys/net/ipv4/ip_dynaddr

    ###########################################################################
    #
    # 4. rules set up.
    #

    ######
    # 4.1 Filter table
    #

    #
    # 4.1.1 Set policies
    #

    $IPTABLES -P INPUT DROP
    $IPTABLES -P OUTPUT DROP
    $IPTABLES -P FORWARD DROP

    #
    # 4.1.2 Create userspecified chains
    #

    #
    # Create chain for bad tcp packets
    #

    $IPTABLES -N bad_tcp_packets

    #
    # Create separate chains for ICMP, TCP and UDP to traverse
    #

    $IPTABLES -N allowed
    $IPTABLES -N icmp_packets

    #
    # 4.1.3 Create content in userspecified chains
    #

    #
    # bad_tcp_packets chain
    #

    $IPTABLES -A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j LOG \
        --log-prefix "New not syn:"
    $IPTABLES -A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j DROP

    #
    # allowed chain
    #

    $IPTABLES -A allowed -p TCP --syn -j ACCEPT
    $IPTABLES -A allowed -p TCP -m state --state ESTABLISHED,RELATED -j ACCEPT
    $IPTABLES -A allowed -p TCP -j DROP

    #
    # ICMP rules
    #

    # Changed rules totally
    $IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 8 -j ACCEPT
    $IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 11 -j ACCEPT

    #
    # 4.1.4 INPUT chain
    #

    #
    # Bad TCP packets we don't want
    #

    $IPTABLES -A INPUT -p tcp -j bad_tcp_packets

    #
    # Packets from the Internet to this box
    #

    $IPTABLES -A INPUT -p ICMP -i $INET_IFACE -j icmp_packets

    #
    # Packets from LAN, DMZ or LOCALHOST
    #

    #
    # From DMZ Interface to DMZ firewall IP
    #

    $IPTABLES -A INPUT -p ALL -i $DMZ_IFACE -d $DMZ_IP -j ACCEPT

    #
    # From LAN Interface to LAN firewall IP
    #

    $IPTABLES -A INPUT -p ALL -i $LAN_IFACE -d $LAN_IP -j ACCEPT
    $IPTABLES -A INPUT -p ALL -i $LAN_IFACE -d $LAN_BROADCAST_ADDRESS -j ACCEPT

    #
    # From Localhost interface to Localhost IP's
    #

    $IPTABLES -A INPUT -p ALL -i $LO_IFACE -s $LO_IP -j ACCEPT
    $IPTABLES -A INPUT -p ALL -i $LO_IFACE -s $LAN_IP -j ACCEPT
    $IPTABLES -A INPUT -p ALL -i $LO_IFACE -s $INET_IP -j ACCEPT

    #
    # Special rule for DHCP requests from LAN, which are not caught properly
    # otherwise.
    #

    $IPTABLES -A INPUT -p UDP -i $LAN_IFACE --dport 67 --sport 68 -j ACCEPT

    #
    # All established and related packets incoming from the internet to the
    # firewall
    #

    $IPTABLES -A INPUT -p ALL -d $INET_IP -m state --state ESTABLISHED,RELATED \
        -j ACCEPT

    #
    # In Microsoft Networks you will be swamped by broadcasts. These lines
    # will prevent them from showing up in the logs.
    #

    #$IPTABLES -A INPUT -p UDP -i $INET_IFACE -d $INET_BROADCAST \
    #--destination-port 135:139 -j DROP

    #
    # If we get DHCP requests from the Outside of our network, our logs will
    # be swamped as well. This rule will block them from getting logged.
    #

    #$IPTABLES -A INPUT -p UDP -i $INET_IFACE -d 255.255.255.255 \
    #--destination-port 67:68 -j DROP

    #
    # If you have a Microsoft Network on the outside of your firewall, you may
    # also get flooded by Multicasts. We drop them so we do not get flooded by
    # logs
    #

    #$IPTABLES -A INPUT -i $INET_IFACE -d 224.0.0.0/8 -j DROP

    #
    # Log weird packets that don't match the above.
    #

    $IPTABLES -A INPUT -m limit --limit 3/minute --limit-burst 3 -j LOG \
        --log-level DEBUG --log-prefix "IPT INPUT packet died: "

    #
    # 4.1.5 FORWARD chain
    #

    #
    # Bad TCP packets we don't want
    #

    $IPTABLES -A FORWARD -p tcp -j bad_tcp_packets

    #
    # DMZ section
    #
    # General rules
    #

    $IPTABLES -A FORWARD -i $DMZ_IFACE -o $INET_IFACE -j ACCEPT
    $IPTABLES -A FORWARD -i $INET_IFACE -o $DMZ_IFACE -m state \
        --state ESTABLISHED,RELATED -j ACCEPT
    $IPTABLES -A FORWARD -i $LAN_IFACE -o $DMZ_IFACE -j ACCEPT
    $IPTABLES -A FORWARD -i $DMZ_IFACE -o $LAN_IFACE -m state \
        --state ESTABLISHED,RELATED -j ACCEPT

    #
    # HTTP server
    #

    $IPTABLES -A FORWARD -p TCP -i $INET_IFACE -o $DMZ_IFACE -d $DMZ_HTTP_IP \
        --dport 80 -j allowed
    $IPTABLES -A FORWARD -p ICMP -i $INET_IFACE -o $DMZ_IFACE -d $DMZ_HTTP_IP \
        -j icmp_packets

    #
    # DNS server
    #

    $IPTABLES -A FORWARD -p TCP -i $INET_IFACE -o $DMZ_IFACE -d $DMZ_DNS_IP \
        --dport 53 -j allowed
    $IPTABLES -A FORWARD -p UDP -i $INET_IFACE -o $DMZ_IFACE -d $DMZ_DNS_IP \
        --dport 53 -j ACCEPT
    $IPTABLES -A FORWARD -p ICMP -i $INET_IFACE -o $DMZ_IFACE -d $DMZ_DNS_IP \
        -j icmp_packets

    #
    # LAN section
    #

    $IPTABLES -A FORWARD -i $LAN_IFACE -j ACCEPT
    $IPTABLES -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

    #
    # Log weird packets that don't match the above.
    #

    $IPTABLES -A FORWARD -m limit --limit 3/minute --limit-burst 3 -j LOG \
        --log-level DEBUG --log-prefix "IPT FORWARD packet died: "

    #
    # 4.1.6 OUTPUT chain
    #

    #
    # Bad TCP packets we don't want.
    #

    $IPTABLES -A OUTPUT -p tcp -j bad_tcp_packets

    #
    # Special OUTPUT rules to decide which IP's to allow.
    #

    $IPTABLES -A OUTPUT -p ALL -s $LO_IP -j ACCEPT
    $IPTABLES -A OUTPUT -p ALL -s $LAN_IP -j ACCEPT
    $IPTABLES -A OUTPUT -p ALL -s $INET_IP -j ACCEPT

    #
    # Log weird packets that don't match the above.
    #

    $IPTABLES -A OUTPUT -m limit --limit 3/minute --limit-burst 3 -j LOG \
        --log-level DEBUG --log-prefix "IPT OUTPUT packet died: "

    ######
    # 4.2 nat table
    #

    #
    # 4.2.1 Set policies
    #

    #
    # 4.2.2 Create user specified chains
    #

    #
    # 4.2.3 Create content in user specified chains
    #

    #
    # 4.2.4 PREROUTING chain
    #

    $IPTABLES -t nat -A PREROUTING -p TCP -i $INET_IFACE -d $HTTP_IP --dport 80 \
        -j DNAT --to-destination $DMZ_HTTP_IP
    $IPTABLES -t nat -A PREROUTING -p TCP -i $INET_IFACE -d $DNS_IP --dport 53 \
        -j DNAT --to-destination $DMZ_DNS_IP
    $IPTABLES -t nat -A PREROUTING -p UDP -i $INET_IFACE -d $DNS_IP --dport 53 \
        -j DNAT --to-destination $DMZ_DNS_IP

    #
    # 4.2.5 POSTROUTING chain
    #

    #
    # Enable simple IP Forwarding and Network Address Translation
    #

    $IPTABLES -t nat -A POSTROUTING -o $INET_IFACE -j SNAT --to-source $INET_IP

    #
    # 4.2.6 OUTPUT chain
    #

    ######
    # 4.3 mangle table
    #

    #
    # 4.3.1 Set policies
    #

    #
    # 4.3.2 Create user specified chains
    #

    #
    # 4.3.3 Create content in user specified chains
    #

    #
    # 4.3.4 PREROUTING chain
    #

    #
    # 4.3.5 INPUT chain
    #

    #
    # 4.3.6 FORWARD chain
    #

    #
    # 4.3.7 OUTPUT chain
    #

    #
    # 4.3.8 POSTROUTING chain
    #
}

--ufw:DMZ_example2() {
    #!/bin/sh
    #
    # rc.DMZ.firewall - DMZ IP Firewall script for Linux 2.4.x
    #
    # Author: Oskar Andreasson <blueflux@koffein.net>
    # (c) of BoingWorld.com, use at your own risk, do whatever you please with
    # it as long as you don't distribute this without due credits to
    # BoingWorld.com
    #

    ###########
    # Configuration options, these will speed you up getting this script to
    # work with your own setup.

    #
    # your LAN's IP range and localhost IP. /24 means to only use the first 24
    # bits of the 32 bit IP adress. the same as netmask 255.255.255.0
    #
    # STATIC_IP is used by me to allow myself to do anything to myself, might
    # be a security risc but sometimes I want this. If you don't have a static
    # IP, I suggest not using this option at all for now but it's stil
    # enabled per default and will add some really nifty security bugs for all
    # those who skips reading the documentation=)

    LAN_IP="192.168.0.2"
    LAN_BCAST_ADRESS="192.168.0.255"
    LAN_IFACE="eth1"

    INET_IP="194.236.50.152"
    INET_IFACE="eth0"

    HTTP_IP="194.236.50.153"
    DNS_IP="194.236.50.154"
    DMZ_HTTP_IP="192.168.1.2"
    DMZ_DNS_IP="192.168.1.3"
    DMZ_IP="192.168.1.1"
    DMZ_IFACE="eth2"

    LO_IP="127.0.0.1"
    LO_IFACE="lo"

    IPTABLES="/usr/local/sbin/iptables"

    ###########################################
    #
    # Load all required IPTables modules unless compiled into the kernel
    #

    #
    # Needed to initially load modules
    #

    /sbin/depmod -a

    #
    # Adds some iptables targets like LOG, REJECT and MASQUARADE.
    #

    /sbin/modprobe ipt_LOG
    /sbin/modprobe ipt_MASQUERADE

    #
    # Support for connection tracking of FTP and IRC.
    #
    #/sbin/modprobe ip_conntrack_ftp
    #/sbin/modprobe ip_conntrack_irc

    #CRITICAL:  Enable IP forwarding since it is disabled by default.
    #

    echo "1" >/proc/sys/net/ipv4/ip_forward

    #
    # Dynamic IP users:
    #
    #echo "1" > /proc/sys/net/ipv4/ip_dynaddr

    ###########################################
    #
    # Chain Policies gets set up before any bad packets gets through
    #

    $IPTABLES -P INPUT DROP
    $IPTABLES -P OUTPUT DROP
    $IPTABLES -P FORWARD DROP

    #
    # the allowed chain for TCP connections, utilized in the FORWARD chain
    #

    $IPTABLES -N allowed
    $IPTABLES -A allowed -p TCP --syn -j ACCEPT
    $IPTABLES -A allowed -p TCP -m state --state ESTABLISHED,RELATED -j ACCEPT
    $IPTABLES -A allowed -p TCP -j DROP

    #
    # ICMP rules, utilized in the FORWARD chain
    #

    $IPTABLES -N icmp_packets
    $IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 0 -j ACCEPT
    $IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 3 -j ACCEPT
    $IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 5 -j ACCEPT
    $IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 11 -j ACCEPT

    ###########################################
    # POSTROUTING chain in the nat table
    #
    # Enable IP SNAT for all internal networks trying to get out on the Internet
    #

    $IPTABLES -t nat -A POSTROUTING -o $INET_IFACE -j SNAT --to-source $INET_IP

    ###########################################
    # PREROUTING chain in the nat table
    #
    # Do some checks for obviously spoofed IP's
    #

    $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -s 192.168.0.0/16 -j DROP
    $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -s 10.0.0.0/8 -j DROP
    $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -s 172.16.0.0/12 -j DROP
    $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -s $INET_IP -j DROP

    #
    # Enable IP Destination NAT for DMZ zone
    #

    $IPTABLES -t nat -A PREROUTING -p TCP -i $INET_IFACE -d $HTTP_IP --dport 80 \
        -j DNAT --to-destination $DMZ_HTTP_IP
    $IPTABLES -t nat -A PREROUTING -p TCP -i $INET_IFACE -d $DNS_IP --dport 53 \
        -j DNAT --to-destination $DMZ_DNS_IP
    $IPTABLES -t nat -A PREROUTING -p UDP -i $INET_IFACE -d $DNS_IP --dport 53 \
        -j DNAT --to-destination $DMZ_DNS_IP

    ###########################################
    #
    # FORWARD chain
    #
    # Get rid of bad TCP packets
    #

    $IPTABLES -A FORWARD -p tcp ! --syn -m state --state NEW -j LOG \
        --log-prefix "New not syn:"
    $IPTABLES -A FORWARD -p tcp ! --syn -m state --state NEW -j DROP

    #
    # DMZ section
    #
    # General rules
    #

    $IPTABLES -A FORWARD -i $DMZ_IFACE -o $INET_IFACE -j ACCEPT
    $IPTABLES -A FORWARD -i $INET_IFACE -o $DMZ_IFACE -m state \
        --state ESTABLISHED,RELATED -j ACCEPT
    $IPTABLES -A FORWARD -i $LAN_IFACE -o $DMZ_IFAC

}
