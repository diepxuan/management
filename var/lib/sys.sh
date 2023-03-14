#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:init")
--sys:init() {
    sudo timedatectl set-timezone Asia/Ho_Chi_Minh

    --user:config $(whoami)
    --git:configure

    --sys:sysctl >/dev/null
    --ufw:iptables >/dev/null

    --server() {
        --cron:install
        --httpd:config
        --ssh:install
    }

    if [[ -n "$*" ]]; then
        "--$*"
    fi
}

_DUCTN_COMMANDS+=("sys:sysctl")
--sys:sysctl() {
    _sysctl="fs.inotify.max_user_watches=524288
net.ipv4.ip_forward=1"

    while IFS= read -r rule; do
        sudo sysctl -w $rule
    done <<<"$_sysctl"

    echo "$_sysctl" | sudo tee /etc/sysctl.d/99-ductn.conf
    sudo sysctl -p
}

_DUCTN_COMMANDS+=("sys:upgrade" "selfupdate")
--selfupdate() { --sys:upgrade; }
--sys:upgrade() {
    sudo apt install --only-upgrade ductn -y --purge --auto-remove
    ductn sys:init
    ductn sys:service:re-install
}
