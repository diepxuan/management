#!/usr/bin/env bash
#!/bin/bash

--sys:init:system_files() {
    rm -rf ~/.vimrc
    # ln $_BASHDIR/.vimrc ~/.vimrc
    # chmod 644 ~/.vimrc

    sed -i 's/.*force_color_prompt\=.*/force_color_prompt\=yes/' ~/.bashrc
    source ~/.bashrc

    echo -e "#!/usr/bin/env bash\n#!/bin/bash\n\n. $_BASHDIR/.bash_aliases" >~/.bash_aliases
    chmod 644 ~/.bash_aliases
    source ~/.bash_aliases

    sudo chown -R ductn:ductn $_BASEDIR
    chmod +x $_BASHDIR/*

    echo -e "#!/usr/bin/env bash\n#!/bin/bash\n\n. $_BASHDIR/ductn" | sudo tee /usr/local/bin/ductn >/dev/null
    sudo chown root:root /usr/local/bin/ductn
    sudo chmod +x /usr/local/bin/ductn
}

_DUCTN_COMMANDS+=("sys:init")
--sys:init() {
    _IS_SERVER="off"
    _IS_SUDOER="off"

    --server() { _IS_SERVER="on"; }
    --admin() { _IS_SUDOER="on"; }

    sudo timedatectl set-timezone Asia/Ho_Chi_Minh

    --sys:init:system_files

    # if [[ -f /etc/resolvconf/resolv.conf.d/head ]]; then
    # echo "nameserver 1.1.1.1" | sudo tee /etc/resolvconf/resolv.conf.d/head >/dev/null
    # fi

    # if [ "$(whoami)" = "ductn" ]; then

    # fi

    --git:configure

    if [[ $_IS_SERVER = "on" ]]; then
        --cron:install
        --httpd:config
        --ssh:install
        # ./bash/ductn --update allowip
        # else
        # sudo mkdir -p /etc/auto.master.d/
        # echo "/dxvn /etc/auto.master.d/dxvn.sshfs --timeout=30" | sudo tee /etc/auto.master.d/dxvn.autofs
        # echo "luong -fstype=nfs,rw,soft,intr,IdentityFile=/home/ductn/.ssh/id_rsa dx1.diepxuan.com:public_html" | sudo tee /etc/auto.master.d/dxvn.sshfs

        # use /etc/fstab
        # sudo mkdir -p /dxvn/luong
        # ductn@dx1.diepxuan.com:/home/ductn/public_html  /dxvn/luong  fuse.sshfs  defaults  0  0
    fi

    if [ $_IS_SUDOER = "on" ] || [ "$(whoami)" = "ductn" ]; then
        echo "ductn ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/90-users >/dev/null
    fi

    # if [ "$(whoami)" = "ductn" ]; then
    # $_BASHDIR/ductn hosts remove 10.8.0.3 dx2
    # $_BASHDIR/ductn hosts remove 10.8.0.2 dx1
    # $_BASHDIR/ductn hosts remove 10.8.0.1 dx3
    # $_BASHDIR/ductn hosts remove 10.8.0.10 vn11
    # $_BASHDIR/ductn hosts remove 10.8.0.11 mg15
    # $_BASHDIR/ductn hosts remove 10.8.0.12 mg15kt

    # $_BASHDIR/ductn hosts remove 10.8.0.2 dx1.diepxuan.com
    # $_BASHDIR/ductn hosts remove 10.8.0.3 dx2.diepxuan.com
    # $_BASHDIR/ductn hosts remove 10.8.0.1 dx3.diepxuan.com
    # fi

}
# . $_BASHDIR/sys.sysctl
