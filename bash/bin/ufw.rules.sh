#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("ufw:iptables")
--ufw:iptables() {
    iptables_path=$(--ufw:iptables:path4)
    ip6tables_path=$(--ufw:iptables:path6)
    iptables_rules_HEAD=""
    iptables_rules_FOOT=""

    _SRV_NUM=$(--host:name)
    _SRV_NUM=${_SRV_NUM:3}

    function _rule_out() {
        _rule=$@
        # [[ -n $_rule ]] && echo -e "ExecStart=$iptables_path\t$_rule" | sudo tee -a /usr/lib/systemd/system/ductn-iptables.service
        [[ -n $_rule ]] && iptables_rules_HEAD="$iptables_rules_HEAD\nExecStart=$iptables_path $_rule"
        _rule=${_rule//'-A '/'-D '}
        _rule=${_rule//'-I '/'-D '}
        # [[ -n $_rule ]] && echo -e "ExecStop=$iptables_path\t$_rule" | sudo tee -a /usr/lib/systemd/system/ductn-iptables.service
        [[ -n $_rule ]] && iptables_rules_FOOT="$iptables_rules_FOOT\nExecStop=$iptables_path $_rule"
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
    fi

    ######### VPN Firewall Site-to-Site #########
    if [[ $(--host:is_server) == 1 ]]; then
        # Allow internet access for vm clients
        _rule_out "-t nat -A POSTROUTING -s '10.0.$_SRV_NUM.0/24' -o vmbr0 -j MASQUERADE"
        _rule_out "-t raw -I PREROUTING -i fwbr+ -j CT --zone 1"
        [[ "$(ip tuntap show | grep tun0)" != "" ]] && _rule_out "-t nat -A POSTROUTING -s '10.0.$_SRV_NUM.0/24' -o tun0 -j MASQUERADE"
        # NAT port to vm client
        _rule_nat "10.0.$_SRV_NUM.10" 3389
        _rule_nat "10.0.$_SRV_NUM.11" 1433
    fi

    ######### VPN Firewall DMZ to Pve server #########
    if [[ $(--host:is_vpn_server) == 1 ]]; then
        _rule_nat "10.8.0.2" 3389
        _rule_nat "10.8.0.2" 1433

        # Do some checks for obviously spoofed IP's
        _INET_IP="$(--ip:wan)"
        _INET_IF="$(route | grep '^default' | grep -o '[^ ]*$')"
        _rule_out "-t nat -A PREROUTING -i $_INET_IF -s $_INET_IP -j DROP"

        # Get rid of bad TCP packets
        _rule_out "-A FORWARD -p tcp ! --syn -m state --state NEW -j LOG --log-prefix \"New not syn: \""
        _rule_out "-A FORWARD -p tcp ! --syn -m state --state NEW -j DROP"

        # General rules
        _rule_out "-A FORWARD -i tun0 -o $_INET_IF -j ACCEPT"
        _rule_out "-A FORWARD -i $_INET_IF -o tun0 -m state --state ESTABLISHED,RELATED -j ACCEPT"

        # "-t nat -A PREROUTING -i $eth0 -p tcp -d ${PUBLIC_IP} --dport 80 -j DNAT --to ${INTERNAL_IP}:80"
        # "-t nat -A PREROUTING -p TCP -i $_INET_IF -d $_INET_IP --dport 80 -j DNAT --to-destination 10.8.0.2"
        # "-t nat -A PREROUTING -p TCP -i $_INET_IF -d $_INET_IP --dport 80 -j DNAT --to-destination 10.8.0.2"
        # "-t nat -A PREROUTING -p TCP -i $_INET_IF -d $_INET_IP --dport 3389 -j DNAT --to-destination 10.8.0.2"
        # -t nat -A PREROUTING -p TCP --dport 3389 -j DNAT --to-destination 10.8.0.2

        # "-t nat -A PREROUTING -p TCP -i $_INET_IF -d $HTTP_IP --dport 80 -j DNAT --to-destination $DMZ_HTTP_IP"

        # -t nat -A POSTROUTING -o $_INET_IF -j SNAT --to-source $_public_ip
        # -t nat -A POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to 10.138.0.2

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

    sudo systemctl daemon-reload
    sudo systemctl enable ductn-iptables
    sudo systemctl restart ductn-iptables
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

--ufw:DMX() {
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
