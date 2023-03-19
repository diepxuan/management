#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("vpn:init")
--vpn:init() {
    for vpn in $(--sys:env:vpn); do
        IFS=':' read -r -a array <<<$vpn
        hostname="${array[0]}"
        address="${array[1]}"

        --hosts:add $address "$hostname.vpn"

        [[ $(--host:name) == $hostname ]] && [[ "$(--vpn:type)" == "server" ]] && --vpn:server:init $hostname
        [[ $(--host:name) == $hostname ]] && [[ "$(--vpn:type)" == "client" ]] && --vpn:client:init $address $hostname
    done
}

--vpn:server:init() {
    hostname=$@

    # push config to client
    if [[ -f /etc/openvpn/server/server.conf ]]; then
        sudo mkdir -p /etc/openvpn/ccd
        echo "ifconfig-push 10.8.0.2 255.255.255.0" | sudo tee /etc/openvpn/ccd/$hostname >/dev/null
    fi

    if [ "$(--sys:service:isactive "openvpn-server@server.service")" == "inactive" ]; then
        # --vpn:openvpn
        echo -e "Please run command 'ductn vpn:openvpn'"
    fi
}

--vpn:client:init() {
    address=$1
    hostname=$2
    --sys:apt:install openvpn
    sudo sed -i 's/.*AUTOSTART="all".*/AUTOSTART="all"/' /etc/default/openvpn >/dev/null

    ssh $address "sudo cat /root/$hostname.ovpn" | sudo tee /etc/openvpn/$hostname.conf >/dev/null

    sudo systemctl daemon-reload
    sudo systemctl enable openvpn@$hostname.service
    sudo systemctl restart openvpn@$hostname.service

}

--vpn:type() {
    if [[ "$(--host:domain)" == "diepxuan.com" ]]; then
        echo "client"
    elif [[ "$(--host:domain)" == "vpn" ]]; then
        echo "server"
    else
        echo "none"
    fi
}

--vpn:openvpn() {
    [ ! -d $USER_BIN_PATH ] && mkdir -p $USER_BIN_PATH
    if [ -z $(command -v openvpn-ubuntu-installer.sh) ]; then
        wget https://git.io/vpn -O $USER_BIN_PATH/openvpn-ubuntu-installer.sh
        chmod +x $USER_BIN_PATH/openvpn-ubuntu-installer.sh
    fi
    [ ! -z "$(command -v openvpn-ubuntu-installer.sh)" ] && sudo $(command -v openvpn-ubuntu-installer.sh)
}
