#!/usr/bin/env bash
#!/bin/bash

# _VPN_PATH=~/easy-rsa

_DUCTN_COMMANDS+=("vpn:init")
--vpn:init() {
    for vpn in $(--sys:env:list "_IPTUNEL"); do
        IFS=':' read -r -a array <<<$vpn
        client="${array[0]}"
        server="${array[1]}"

        --hosts:add $serve "$client.vpn"

        [[ $(--host:name) == $client ]] && --vpn:server "$client"
        [[ $(--host:name) == $client ]] && --vpn:client $serve $client

        # 35.230.52.242
        # [[ "$(ductn host:name)" == "pve2" ]] && echo 1 || echo 0
    done
}

--vpn:server:init() {
    --vpn:openvpn
    # cd $_VPN_PATH
    # $_VPN_PATH/easyrsa init-pki

    # $_VPN_PATH/easyrsa gen-req server nopass
    # sudo cp $_VPN_PATH/pki/private/server.key /etc/openvpn/server/

    # if [ -d /etc/ssh/sshd_config.d/ ]; then
    # echo -e "PermitRootLogin without-password\nPermitTunnel yes" | sudo tee /etc/ssh/sshd_config.d/99-vpn.conf >/dev/null
    # echo -e "PermitRootLogin without-password\nPermitTunnel point-to-point" | sudo tee /etc/ssh/sshd_config.d/99-vpn.conf >/dev/null
    # sudo systemctl restart sshd.service
    # fi

    # sudo ip tuntap add mode tun dev tun0

    # sudo sysctl -w net.ipv4.ip_forward=1
    # echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-vpn.conf

    # sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o ens4 -j MASQUERADE
    # sudo bash -c "iptables-save > /etc/iptables.rules"
    # iptables-restore < /etc/iptables.rules
}

--vpn:server() {
    [[ "$(--vpn:type)" == "server" ]] && --vpn:server:init
}

--vpn:client:init() {
    $server=$1
    $client=$2
    --sys:apt:install openvpn
    sudo sed -i 's/.*AUTOSTART="all"/AUTOSTART="all"/' /etc/default/openvpn >/dev/null

    ssh $server "sudo cat /root/$client.ovpn" | tee ~/$client.ovpn >/dev/null
    # sudo openvpn --config ~/$client.ovpn
    sudo cp ~/$client.ovpn /etc/openvpn/$client.conf

    # Authenicate by pass
    # check ‘auth-user-pass’ to ‘auth-user-pass pass’ in ovpn
    # echo -e "<IVPN Account ID>\n<IVPN Account Pass>" | sudo tee /etc/openvpn/pass >/dev/null
    # sudo chmod 400 /etc/openvpn/pass

    sudo systemctl enable openvpn@$client.service
    sudo systemctl daemon-reload
    sudo systemctl restart openvpn@$client.service

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

--vpn:client() {
    [[ "$(--vpn:type)" == "client" ]] && --vpn:client:init $@
}

--vpn:type() {
    [[ "$(--host:domain)" == "diepxuan.com" ]] && echo "client"
    [[ "$(--host:domain)" == "vpn" ]] && echo "server"
    echo "none"
    exit 1
}

--vpn:openvpn() {
    [ ! -d $USER_BIN_PATH ] && mkdir -p $USER_BIN_PATH
    if [ ! -x $(command -v openvpn-ubuntu-installer.sh) ]; then
        wget https://git.io/vpn -O $USER_BIN_PATH/openvpn-ubuntu-installer.sh
        chmod +x $USER_BIN_PATH/openvpn-ubuntu-installer.sh
    else
        sudo $(command -v openvpn-ubuntu-installer.sh)
    fi

    echo 1 # missing command openvpn-ubuntu-installer.sh

    # --sys:apt:install openvpn easy-rsa

    # if [ ! -d $_VPN_PATH ]; then
    #     # echo -e "PermitRootLogin without-password\nPermitTunnel yes" | sudo tee /etc/ssh/sshd_config.d/99-vpn.conf >/dev/null
    #     # echo -e "PermitRootLogin without-password\nPermitTunnel point-to-point" | sudo tee /etc/ssh/sshd_config.d/99-vpn.conf >/dev/null
    #     # sudo systemctl restart sshd.service

    #     mkdir $_VPN_PATH
    #     ln -s /usr/share/easy-rsa/* $_VPN_PATH
    #     chmod 700 $_VPN_PATH

    #     echo -e "$_EASY_VARS" >$_VPN_PATH/vars

    #     cd $_VPN_PATH
    #     $_VPN_PATH/easyrsa init-pki
    # fi
}

_EASY_VARS='
set_var EASYRSA_REQ_COUNTRY    "NV"
set_var EASYRSA_REQ_PROVINCE   "QuangBinh"
set_var EASYRSA_REQ_CITY       "Dong Hoi City"
set_var EASYRSA_REQ_ORG        "DiepXuan"
set_var EASYRSA_REQ_EMAIL      "ductn@diepxuan.com"
set_var EASYRSA_REQ_OU         "Community"
set_var EASYRSA_ALGO           "ec"
set_var EASYRSA_DIGEST         "sha512"
'
