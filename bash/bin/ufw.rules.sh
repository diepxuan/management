#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("ufw:iptables")
--ufw:iptables() {
    iptables_path=$(--ufw:iptables:path4)
    ip6tables_path=$(--ufw:iptables:path6)
    iptables_rules_HEAD=""
    iptables_rules_FOOT=""

    function _rule_out() {
        _rule=$@
        # [[ -n $_rule ]] && echo -e "ExecStart=$iptables_path\t$_rule" | sudo tee -a /usr/lib/systemd/system/ductn-iptables.service
        [[ -n $_rule ]] && iptables_rules_HEAD="$iptables_rules_HEAD\nExecStart=$iptables_path $_rule"
        _rule=${_rule//'-A '/'-D '}
        _rule=${_rule//'-I '/'-D '}
        # [[ -n $_rule ]] && echo -e "ExecStop=$iptables_path\t$_rule" | sudo tee -a /usr/lib/systemd/system/ductn-iptables.service
        [[ -n $_rule ]] && iptables_rules_FOOT="$iptables_rules_FOOT\nExecStop=$iptables_path $_rule"
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

    ######### VPN Firewall #########
    if [[ $(--host:is_server) == 1 ]]; then
        _SRV_NUM=$(--host:name)
        _SRV_NUM=${_SRV_NUM:3}
        _rule_out "-t nat -A POSTROUTING -s '10.0.$_SRV_NUM.0/24' -o vmbr0 -j MASQUERADE"
        _rule_out "-t raw -I PREROUTING -i fwbr+ -j CT --zone 1"
        [[ "$(ip tuntap show | grep tun0)" != "" ]] && _rule_out="-t nat -A POSTROUTING -s '10.0.$_SRV_NUM.0/24' -o tun0 -j MASQUERADE"
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

    # sudo systemctl daemon-reload
    # sudo systemctl enable ductn-iptables # remove the extension
    # sudo systemctl restart ductn-iptables
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
