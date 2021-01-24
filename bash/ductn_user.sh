#!/bin/bash

--new() {
    #!/bin/bash

    sudo adduser ${1} --disabled-password --gecos \"\"
    sudo adduser ${1} www-data
    usermod -aG www-data ${1}
    id -u ${1}

    --config $@
}

--config() {
    sudo mkdir -p /home/${1}/.ssh
    sudo chmod 777 /home/${1}/.ssh

    if [[ ${1} = "ductn" ]]; then
        echo "ductn ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/90-users >/dev/null
    else
        cat ~/.ssh/id_rsa | sudo tee /home/${1}/.ssh/id_rsa >/dev/null
        cat ~/.ssh/id_rsa.pub | sudo tee /home/${1}/.ssh/id_rsa.pub >/dev/null
        cat ~/.ssh/authorized_keys | sudo tee /home/${1}/.ssh/authorized_keys >/dev/null
    fi
    echo ". /var/www/base/bash/.bash_aliases" /home/${1}/.bash_aliases >/dev/null

    sudo chmod 755 /home/${1}
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

--admin() {
    echo "ductn ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/90-users >/dev/null
}

$@
