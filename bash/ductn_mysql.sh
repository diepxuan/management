#!/bin/sh

--install() {
    --swap --install
    sudo apt install -y --purge --auto-remove mysql-server
    # sudo mysql_secure_installation
}

$@
