#!/usr/bin/env bash
#!/bin/bash

_SSHDIR="~/.ssh"

_DUCTN_COMMANDS+=("user:new")
--user:new() {
    #!/bin/bash

    sudo adduser ${1} --disabled-password --gecos \"\"
    sudo adduser ${1} www-data
    sudo usermod -aG www-data ${1}
    id -u ${1}

    --user:config ${1}
}

_DUCTN_COMMANDS+=("user:config")
--user:config() {
    if [[ ${1} = "ductn" ]]; then
        --user:config:ssh ${1}
        --user:config:admin

        sudo usermod -aG mssql ${1} >/dev/null 2>&1
    fi

    --user:config:bash ${1}
    --user:config:chmod ${1}
}

--user:config:bash() {
    sudo sed -i 's/.*force_color_prompt\=.*/force_color_prompt\=yes/' /home/${1}/.bashrc >/dev/null
}

--user:config:ssh() {
    sudo mkdir -p /home/${1}/.ssh

    cat $_SSHDIR/id_rsa | sudo tee /home/${1}/.ssh/id_rsa >/dev/null
    cat $_SSHDIR/id_rsa.pub | sudo tee /home/${1}/.ssh/id_rsa.pub >/dev/null
    cat $_SSHDIR/id_rsa.pub | sudo tee --append /home/${1}/.ssh/authorized_keys >/dev/null

    sudo chown -R ${1}:${1} /home/${1}/.ssh
}

--user:config:chmod() {
    sudo chmod 755 /home/${1}

    sudo mkdir -p /home/${1}/.ssh
    sudo chmod 777 /home/${1}/.ssh

    sudo chmod -R 600 /home/${1}/.ssh
    sudo chmod 700 /home/${1}/.ssh
    sudo chown -R ${1}:${1} /home/${1}/.ssh

    sudo chmod 644 /home/${1}/.bash_aliases
    sudo chown -R ${1}:${1} /home/${1}/.bash_aliases

    sudo mkdir -p /home/${1}/public_html
    sudo chmod 755 /home/${1}/public_html
    sudo chown -R ${1}:www-data /home/${1}/public_html

    sudo mkdir -p /home/${1}/.ssl
    sudo chown -R ${1}:${1} /home/${1}/.ssl
}

--user:config:admin() {
    echo "ductn ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/90-users >/dev/null
}
