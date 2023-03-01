#!/usr/bin/env bash
#!/bin/bash

--sys:apt:fix() {
    --apt:fix
}

--sys:apt:check() {
    dpkg -s $1 2>/dev/null | grep 'install ok installed' >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo 0
    else
        echo 1
    fi

    # REQUIRED_PKG=$1
    # PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG | grep "install ok installed")
    # # echo Checking for $REQUIRED_PKG: $PKG_OK
    # if [ "" = "$PKG_OK" ]; then
    #     #     echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
    #     #     sudo apt-get --yes install $REQUIRED_PKG
    #     echo 0
    # else
    #     echo 1
    # fi

}

--sys:apt:install() {
    if [[ "$(--sys:apt:check $@)" -eq 0 ]]; then
        sudo apt install $@ -y --purge --auto-remove
    fi
}

--sys:apt:remove() {
    sudo apt remove $@ -y --purge --auto-remove
}
