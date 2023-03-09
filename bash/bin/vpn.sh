#!/usr/bin/env bash
#!/bin/bash

# _VPN_PATH=~/easy-rsa
_IPTUNEL="pve2:34.170.109.33"

_DUCTN_COMMANDS+=("vpn:init")
--vpn:init() {
    for vpn in $(--sys:env:list _IPTUNEL); do
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

    if [ "$(--sys:service:isactive "openvpn-server@server.service")" == "inactive" ]; then
        # --vpn:openvpn
        echo -e "Please run command 'ductn vpn:openvpn'"

        # sudo openvpn --genkey --secret /etc/openvpn/server/ta.key
        #         echo -e "# Site-to-site
        # client-config-dir /etc/openvpn/ccd
        # tls-auth ta.key 0" | sudo tee -a /etc/openvpn/server/server.conf
    fi

    # push config to client
    if [[ -f /etc/openvpn/server/server.conf ]]; then
        sudo mkdir -p /etc/openvpn/ccd
        #     if [[ ! -n $(grep -P "client-config-dir" /etc/openvpn/server/server.conf) ]]; then
        #         echo -e "client-config-dir /etc/openvpn/ccd" | sudo tee -a /etc/openvpn/server/server.conf >/dev/null
        #     else
        #         sudo sed -i 's/client-config-dir .*/client-config-dir \/etc\/openvpn\/ccd/' /etc/openvpn/server/server.conf >/dev/null
        #     fi
        echo "ifconfig-push 10.8.0.2 255.255.255.0" | sudo tee /etc/openvpn/ccd/$hostname >/dev/null
    fi

}

--vpn:client:init() {
    address=$1
    hostname=$2
    --sys:apt:install openvpn
    sudo sed -i 's/.*AUTOSTART="all".*/AUTOSTART="all"/' /etc/default/openvpn >/dev/null

    ssh $address "sudo cat /root/$hostname.ovpn" | sudo tee /etc/openvpn/$hostname.conf >/dev/null

    # sudo openvpn --config ~/$hostname.ovpn
    # sudo cp ~/$hostname.ovpn /etc/openvpn/$hostname.conf

    # Authenicate by pass
    # check ‘auth-user-pass’ to ‘auth-user-pass pass’ in ovpn
    # echo -e "<IVPN Account ID>\n<IVPN Account Pass>" | sudo tee /etc/openvpn/pass >/dev/null
    # sudo chmod 400 /etc/openvpn/pass

    sudo systemctl enable openvpn@$hostname.service
    sudo systemctl daemon-reload
    sudo systemctl restart openvpn@$hostname.service

    # --vpn:openvpn
    # cd $_VPN_PATH
    # mkdir -p $_VPN_PATH/pki/reqs/
    # $_VPN_PATH/easyrsa init-pki
    # $_VPN_PATH/easyrsa gen-req server nopass

    # scp $serve:$_VPN_PATH/pki/reqs/server.req $DIRTMP/server.req
    # $_VPN_PATH/easyrsa import-req $DIRTMP/server.req server
    # $_VPN_PATH/easyrsa build-ca
    # $_VPN_PATH/easyrsa sign-req server server

    # [ ! -x "$(command -v autossh)" ] && --sys:apt:install autossh
    # source /etc/network/interfaces.d/*

    # autossh -M 0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -NTC -o Tunnel=point-to-point -w 0:0 $@ &
    # echo "autossh -M 0 -o \"ServerAliveInterval 30\" -o \"ServerAliveCountMax 3\" -NTC -o Tunnel=point-to-point -w 0:0 $@"
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
