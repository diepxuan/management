#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("ufw:geoip:install")
--ufw:geoip:install() {
    sudo apt install curl unzip perl -y --purge --auto-remove
    sudo apt install xtables-addons-common -y --purge --auto-remove
    sudo apt install libtext-csv-xs-perl libmoosex-types-netaddr-ip-perl -y --purge --auto-remove
}

_DUCTN_COMMANDS+=("ufw:geoip:update")
--ufw:geoip:update() {
    MON=$(date +"%m")
    YR=$(date +"%Y")
    sudo mkdir -p /usr/share/xt_geoip
    sudo chmod +x /usr/lib/xtables-addons/*

    sudo rm /usr/share/xt_geoip/dbip-country-lite.csv
    (cd /usr/share/xt_geoip && sudo /usr/lib/xtables-addons/xt_geoip_dl)

    # sudo wget https://download.db-ip.com/free/dbip-country-lite-${YR}-${MON}.csv.gz -O /usr/share/xt_geoip/dbip-country-lite.csv.gz
    # sudo gunzip /usr/share/xt_geoip/dbip-country-lite.csv.gz

    sudo /usr/lib/xtables-addons/xt_geoip_build -D /usr/share/xt_geoip/ -S /usr/share/xt_geoip/
    sudo rm /usr/share/xt_geoip/dbip-country-lite.csv
}

_DUCTN_COMMANDS+=("ufw:geoip:configuration")
--ufw:geoip:configuration() {
    --ufw:geoip:update
    sudo modprobe xt_geoip
    # lsmod | grep ^xt_geoip
    # iptables -m geoip -h

    ##########################
    # /etc/ufw/before.rules  #
    # /etc/ufw/before6.rules #
    ##########################
    # GeoIp
    # -A ufw-before-input -m geoip ! --src-cc VN -j LOG --log-prefix "[BLOCKED COUNTRIES] "
    # -A ufw-before-input -m geoip ! --src-cc VN -j DROP
}

_DUCTN_COMMANDS+=("ufw:geoip:allowCloudflare")
--ufw:geoip:allowCloudflare() {
    # Allow Cloudflare IP
    # https://www.cloudflare.com/ips-v4
    # https://www.cloudflare.com/ips-v6
    # iptables -I INPUT -p tcp -m multiport --dports http,https -s $ip -j ACCEPT
    # -A ufw-before-input -p tcp -m multiport --dports http,https -s $ip -j ACCEPT

    v4ips="https://www.cloudflare.com/ips-v4"
    echo "# v4: add to file /etc/ufw/before.rules"
    echo "########################################"
    while IFS= read -r line; do
        echo "-A ufw-before-input -p tcp -m multiport --dports http,https -s ${line} -j ACCEPT"
    done < <(curl -s $v4ips)

    echo -e "\n\n"

    v6ips="https://www.cloudflare.com/ips-v6"
    echo "# v6: add to file /etc/ufw/before6.rules"
    echo "########################################"
    while IFS= read -r line; do
        echo "-A ufw-before-input -p tcp -m multiport --dports http,https -s ${line} -j ACCEPT"
    done < <(curl -s $v6ips)
}
