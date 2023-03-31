#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("user:new")
--user:new() {
    user=$1

    sudo adduser $user --disabled-password --gecos \"\"
    sudo adduser $user www-data
    sudo usermod -aG www-data $user
    id -u $user

    sudo mkdir -p /home/$user/.ssh
    cat ~/.ssh//id_rsa.pub | sudo tee --append /home/$user/.ssh/authorized_keys >/dev/null

    --user:config $user
}

_DUCTN_COMMANDS+=("user:config")
--user:config() {
    if [[ $1 = "ductn" ]]; then
        --user:config:admin

        sudo usermod -aG mssql $1 >/dev/null 2>&1
        sudo usermod -aG www-data $1 >/dev/null 2>&1
    fi

    --user:config:bash $1
    --user:config:chmod $1
}

--user:config:bash() {
    local user=$1
    sudo sed -i 's/.*force_color_prompt\=.*/force_color_prompt\=yes/' /home/$user/.bashrc >/dev/null
    sudo sed -i "s|.*/var/www/base/bash/.bash_aliases.*||" /home/$user/.bash_aliases >/dev/null

    local match="########## DUCTN Aliases ##########"
    local aliases=/home/$user/.bash_aliases
    local match_index=$(grep "$match" $aliases | wc -l)

    if [[ $match_index == 0 ]]; then
        echo $match | sudo tee -a $aliases >/dev/null
        echo $match | sudo tee -a $aliases >/dev/null
    elif [[ $match_index == 1 ]]; then
        sudo sed -i "/$match/a\\$match" $aliases
    fi

    cat <<'EOF' | sudo sed -i -e "/$match/{:a;N;/\n$match$/!ba;r /dev/stdin" -e ";d}" $aliases
########## DUCTN Aliases ##########
# composer PATH
export PATH=$PATH:$HOME/bin:$HOME/.composer/vendor/bin
[ -d $HOME/.config/composer ] && export PATH=$PATH:$HOME/.config/composer/vendor/bin
[ -d $HOME/.composer ] && export PATH=$PATH:$HOME/.composer/vendor/bin

# Missing command
alias ll >/dev/null 2>&1 || alias ll="ls -alF"

# mssql-server PATH
[ -d /opt/mssql-tools/bin/ ] && PATH="$PATH:/opt/mssql-tools/bin"
[ -d /opt/mssql/bin/ ] && PATH="$PATH:/opt/mssql/bin"
########## DUCTN Aliases ##########
EOF
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

--user:is_sudoer() {
    local user=$(whoami)
    [[ -n $1 ]] && user=$1
    [[ -n $(groups $user | grep -e 'sudo\|root') ]]
}
