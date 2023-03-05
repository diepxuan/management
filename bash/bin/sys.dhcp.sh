#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:dhcp:setup")
--sys:dhcp:setup() {
    if [ $(--host:is_server) = 1 ]; then
        --sys:apt:install isc-dhcp-server

        --sys:dhcp:config
    fi
}

--sys:dhcp:config() {
    _DHCP_DEFAULT=/etc/default/isc-dhcp-server

    ### /etc/default/isc-dhcp-server
    sudo sed -i 's/INTERFACES=.*/INTERFACES="vmbr1"/' $_DHCP_DEFAULT >/dev/null
    sudo sed -i 's/INTERFACESv4=.*/INTERFACESv4="vmbr1"/' $_DHCP_DEFAULT >/dev/null
    # sudo sed -i 's/INTERFACESv6=.*/INTERFACESv6="vmbr1"/' $_DHCP_DEFAULT >/dev/null

    ### /etc/dhcp/dhcpd.conf
    [ ! -f /etc/dhcp/dhcpd.conf.org ] && sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.org
    echo -e "$_DHCPD_CONF" | sudo tee /etc/dhcp/dhcpd.conf >/dev/null

    sudo killall dhcpd
    sudo rm -rf /var/run/dhcpd.pid
    --sys:service:restart isc-dhcp-server
}
_DHCPD_HOST=$(--host:name)
_DHCPD_HOST=${_DHCPD_HOST:3}
_DHCPD_CONF="
option domain-name \"diepxuan.com\";
option domain-search \"diepxuan.com\";
option domain-name-servers 1.1.1.1, 10.0.1.10, 10.0.2.10;

default-lease-time 600;
max-lease-time 7200;

ddns-update-style none;
authoritative;

one-lease-per-client true;
deny duplicates;
update-conflict-detection false;

subnet 10.0.$_DHCPD_HOST.0 netmask 255.255.255.0 {
    pool {
        option domain-name-servers 1.1.1.1,10.0.1.10,10.0.2.10;
        range 10.0.$_DHCPD_HOST.150 10.0.$_DHCPD_HOST.199;
    }

    option domain-name-servers 1.1.1.1,10.0.1.10,10.0.2.10;

    option routers 10.0.$_DHCPD_HOST.1;
    option subnet-mask 255.255.255.0;

    ping-check true;
}

host dc1 {
        hardware ethernet ba:1f:4a:6a:63:a1;
        fixed-address 10.0.1.10;
        option host-name \"dc1\";
}

host dc2 {
    hardware ethernet 62:F0:9D:12:02:61;
    fixed-address 10.0.2.10;
    option host-name \"dc2\";
}

host sql2 {
    hardware ethernet 16:13:D5:80:B3:58;
    fixed-address 10.0.2.11;
    option host-name \"sql2\";
}

host sql1 {
        hardware ethernet ae:fa:53:5f:00:f1;
        fixed-address 10.0.1.11;
        option host-name \"sql1\";
}
"
