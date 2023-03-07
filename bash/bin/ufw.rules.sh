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
        [[ -z "$_port" ]] && _port="--dport $_port" || _port=""
        [[ -n $_ip ]] && _rule_out "-t nat -A PREROUTING -p TCP $_port -j DNAT --to-destination $ip"
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

        # _INET_IP="$(--ip:wan)"
        # _INET_IF="$(route | grep '^default' | grep -o '[^ ]*$')"

        # "-t nat -A PREROUTING -i $eth0 -p tcp -d ${PUBLIC_IP} --dport 80 -j DNAT --to ${INTERNAL_IP}:80"
        # "-t nat -A PREROUTING -p TCP -i $_INET_IF -d $_INET_IP --dport 80 -j DNAT --to-destination 10.8.0.2"
        # "-t nat -A PREROUTING -p TCP -i $_INET_IF -d $_INET_IP --dport 80 -j DNAT --to-destination 10.8.0.2"
        # "-t nat -A PREROUTING -p TCP -i $_INET_IF -d $_INET_IP --dport 3389 -j DNAT --to-destination 10.8.0.2"
        # -t nat -A PREROUTING -p TCP --dport 3389 -j DNAT --to-destination 10.8.0.2

        # "-t nat -A PREROUTING -p TCP -i $INET_IFACE -d $HTTP_IP --dport 80 -j DNAT --to-destination $DMZ_HTTP_IP"

        # -t nat -A POSTROUTING -o $INET_IFACE -j SNAT --to-source $_public_ip
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
WantedBy=multi-user.target" | sudo tee /usr/lib/systemd/system/ductn-iptables.service >/dev/null

    # cat /usr/lib/systemd/system/ductn-iptables.service

    # sudo  systemctl enable --now ductn-iptables.service

    sudo systemctl daemon-reload
    sudo systemctl enable ductn-iptables # remove the extension
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
