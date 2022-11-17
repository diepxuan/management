#!/usr/bin/env bash
#!/bin/bash

--sys:apt:fix() {
    --apt:fix
}

--sys:apt:check() {
    dpkg -s $1 | grep 'Status: install ok installed' >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo 1
    else
        echo 0
    fi
}

--sys:apt:install() {
    if [[ "$(--sys:apt:check $@)" -eq 1 ]]; then
        sudo apt -q install $@ -y --purge --auto-remove >/dev/null 2>&1
    fi
}
