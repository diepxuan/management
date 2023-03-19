#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("ufw:geoip:uninstall")
--ufw:geoip:uninstall() {
    # sudo apt remove curl unzip perl -y --purge --auto-remove
    sudo apt remove xtables-addons-common -y --purge --auto-remove
    sudo apt remove libtext-csv-xs-perl libmoosex-types-netaddr-ip-perl -y --purge --auto-remove
    sudo apt remove libnet-cidr-lite-perl -y --purge --auto-remove
}

_DUCTN_COMMANDS+=("ufw:geoip:allowCloudflare")
--ufw:geoip:allowCloudflare() {
    # Allow Cloudflare IP
    # https://www.cloudflare.com/ips-v4
    # https://www.cloudflare.com/ips-v6
    # iptables -I INPUT -p tcp -m multiport --dports http,https -s $ip -j ACCEPT
    # -A ufw-before-input -p tcp -m multiport --dports http,https -s $ip -j ACCEPT

    v4ips="https://www.cloudflare.com/ips-v4"
    # echo "# v4: add to file /etc/ufw/before.rules"
    # echo "########################################"
    while IFS= read -r line; do
        echo -e "-A ufw-before-input -p tcp -m multiport --dports http,https -s ${line} -j ACCEPT\n"
    done < <(curl -s $v4ips)

    echo -e "\n\n"

    v6ips="https://www.cloudflare.com/ips-v6"
    # echo "# v6: add to file /etc/ufw/before6.rules"
    # echo "########################################"
    while IFS= read -r line; do
        # echo -e "-A ufw-before-input -p tcp -m multiport --dports http,https -s ${line} -j ACCEPT\n"
        echo ''
    done < <(curl -s $v6ips)
}
