#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:sysctl")
--sys:sysctl() {
    _sysctl="fs.inotify.max_user_watches=524288
net.ipv4.ip_forward=1"

    while IFS= read -r rule; do
        sudo sysctl -w $rule
    done <$_sysctl

    echo "$_sysctl" | sudo tee /etc/sysctl.d/99-ductn.conf
    sudo sysctl -p
}
