#!/usr/bin/env bash
#!/bin/bash

--sys:service:valid() {
    --sys:service:httpd
    --sys:service:mysql
    --sys:service:mssql
    --sys:service:vpn
}

--sys:service:httpd() {
    if [ "$(--sys:service:isactive apache2)" == "failed" ]; then
        --swap:install
        --log:cleanup
        --sys:service:restart apache2
    fi

    # sudo /usr/sbin/service apache2 status | grep 'active' >/dev/null 2>&1
    # if [ $? != 0 ]; then
    #     sudo /usr/sbin/service apache2 start
    # fi
}

--sys:service:mysql() {
    if [ "$(--sys:service:isactive mysql)" == "failed" ]; then
        --swap:install
        --log:cleanup
        --sys:service:restart mysql
    fi

    # sudo /usr/sbin/service mysql status | grep 'active' >/dev/null 2>&1
    # if [ $? != 0 ]; then
    #     --swap:install
    #     --log:cleanup
    #     sudo /usr/sbin/service mysql start
    # fi
}

--sys:service:mssql() {
    if [ "$(--sys:service:isactive mssql-server)" == "failed" ]; then
        --swap:install
        --log:cleanup
        --sys:service:restart mssql-server
    fi

    # sudo /usr/sbin/service mssql-server status | grep 'active' >/dev/null 2>&1
    # if [ $? != 0 ]; then
    #     --swap:install
    #     --log:cleanup
    #     sudo /usr/sbin/service mssql-server start
    # fi
}

--sys:service:ufw() {
    if [ "$(--sys:service:isactive ufw)" == "failed" ]; then
        [[ $(--sys:ufw:is_exist) -eq 1 ]] && sudo ufw enable
    fi

    # sudo ufw status | grep ' active' >/dev/null 2>&1
    # if [ $? != 0 ]; then
    #     sudo ufw enable
    # fi
}

--sys:service:vpn() {
    if [[ "$(--vpn:type)" == "client" ]]; then
        _SERVICE="openvpn@$(--host:name).service"
        if [ "$(--sys:service:isactive $_SERVICE)" == "failed" ]; then
            --vpn:init
            --sys:service:restart $_SERVICE
        fi
    fi

    if [[ "$(--vpn:type)" == "server" ]]; then
        _SERVICE="openvpn-server@server.service"
        if [ "$(--sys:service:isactive $_SERVICE)" == "failed" ]; then
            --vpn:init
            --sys:service:restart $_SERVICE
        fi
    fi

    # sudo ufw status | grep ' active' >/dev/null 2>&1
    # if [ $? != 0 ]; then
    #     sudo ufw enable
    # fi
}

--sys:service:dhcp() {
    if [ $(--host:is_server) = 1 ] && [ "$(--sys:service:isactive isc-dhcp-server)" == "failed" ]; then
        sudo killall dhcpd
        sudo rm -rf /var/run/dhcpd.pid
        --sys:service:restart isc-dhcp-server
    fi
}

--sys:service:iptables() {
    # DescriptionRemoved from 3.0.4-2
    return 0
    if [[ ! "$(--sys:service:isactive ductn-iptables)" == "active" ]]; then
        --ufw:iptables
    fi
}
