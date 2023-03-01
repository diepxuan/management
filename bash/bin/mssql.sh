#!/usr/bin/env bash
#!/bin/bash

--sqlsrv:apt:install() {
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    # sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2019.list)"
    # sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/mssql-server-2019.list)"
    sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2019.list)"
    # sudo apt update
}

_DUCTN_COMMANDS+=("sqlsrv:install")
--sqlsrv:install() {
    --sqlsrv:apt:install

    # Install SQL Server
    ####################
    sudo apt install -y mssql-server

    # Configration SQL Server
    ####################
    sudo /opt/mssql/bin/mssql-conf setup
}

_DUCTN_COMMANDS+=("mssql:install")
--mssql:install() {
    --sqlsrv:install
}

--sqlsrv:cron() {
    --sqlsrv:install
}
