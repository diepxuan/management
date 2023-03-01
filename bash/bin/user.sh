#!/usr/bin/env bash
#!/bin/bash

# options_found=0
# while getopts ":u" opt; do
#     options_found=1
#     case $opt in
#     u)
#         username=$OPTARG
#         echo "username = $OPTARG"
#         ;;
#     esac
# done

# if ((!options_found)); then
#     echo "no options found"
# fi

_SSHDIR="$_LIBDIR/ssh"

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
        --user:config:admin
    fi

    --user:config:bash ${1}
    --user:config:ssh ${1}
    --user:config:chmod ${1}
}

--user:config:bash() {
    sudo touch /home/${1}/.bash_aliases
    echo ". /var/www/base/bash/.bash_aliases" | sudo tee /home/${1}/.bash_aliases >/dev/null

    sudo chmod 644 /home/${1}/.bash_aliases
    sudo chown -R ${1}:${1} /home/${1}/.bash_aliases
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
