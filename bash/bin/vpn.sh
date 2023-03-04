#!/usr/bin/env bash
#!/bin/bash

# _VPN_PATH=~/easy-rsa

_DUCTN_COMMANDS+=("vpn:init")
--vpn:init() {
    for vpn in $(--sys:env:list _IPTUNEL); do
        IFS=':' read -r -a array <<<$vpn
        hostname="${array[0]}"
        address="${array[1]}"

        --hosts:add $address "$hostname.vpn"

        [[ $(--host:name) == $hostname ]] && --vpn:server $hostname
        [[ $(--host:name) == $hostname ]] && --vpn:client $address $hostname
    done
}

--vpn:server:init() {
    hostname=$@
    # if [ "$(--sys:service:isactive "openvpn-server@server.service")" == "inactive" ]; then
    # echo -e "Please run command 'ductn vpn:openvpn'"
    # fi

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

    # push config to client
    # if [[ -f /etc/openvpn/server/server.conf ]]; then
    #     sudo mkdir /etc/openvpn/server/ccd
    #     if [[ ! -n $(grep -P "client-config-dir" /etc/openvpn/server/server.conf) ]]; then
    #         echo -e "client-config-dir /etc/openvpn/server/ccd" | sudo tee -a /etc/openvpn/server/server.conf >/dev/null
    #     else
    #         sudo sed -i 's/client-config-dir .*/client-config-dir \/etc\/openvpn\/server\/ccd/' /etc/openvpn/server/server.conf >/dev/null
    #     fi
    # fi

    # push "route 10.10.0.0 255.255.255.0"
    # /etc/openvpn/server/server.conf
    # _SRV_NUM=${hostname:3}
    # _SRV_NUM=10.0.$_SRV_NUM.0
    # --vpn:server:client_router $_SRV_NUM 255.255.255.0

    # --sys:service:restart openvpn-server@server.service
}

# --vpn:server:client_router() {
#     _router="push \"route $1 $2\""
#     if [[ -f /etc/openvpn/server/server.conf ]] && [[ ! -n $(grep -P "push.*$1.*" /etc/openvpn/server/server.conf) ]]; then
#         echo -e $_router | sudo tee -a /etc/openvpn/server/server.conf >/dev/null
#     fi
# }

--vpn:server() {
    [[ "$(--vpn:type)" == "server" ]] && --vpn:server:init $hostname
}

--vpn:client:init() {
    address=$1
    hostname=$2
    --sys:apt:install openvpn
    sudo sed -i 's/.*AUTOSTART="all".*/AUTOSTART="all"/' /etc/default/openvpn >/dev/null

    ssh $address "sudo cat /root/$hostname.ovpn" | sudo tee /etc/openvpn/$hostname.conf >/dev/null
    sudo mkdir -p /etc/openvpn/server/ccd
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

--vpn:client() {
    [[ "$(--vpn:type)" == "client" ]] && --vpn:client:init $@
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
    if [ ! -x $(command -v openvpn-ubuntu-installer.sh) ]; then
        wget https://git.io/vpn -O $USER_BIN_PATH/openvpn-ubuntu-installer.sh
        chmod +x $USER_BIN_PATH/openvpn-ubuntu-installer.sh
    else
        [ -x "$(command -v openvpn-ubuntu-installer.sh)" ] && sudo $(command -v openvpn-ubuntu-installer.sh)
    fi

    # exit 1 # missing command openvpn-ubuntu-installer.sh

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
