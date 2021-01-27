#!/usr/bin/env bash

# install to vps
# ################################################################
# cat .bash_aliases | ssh evolveretail.twtools "cat > $HOME/.bash_aliases"

# start symbol
# ################################################################
PS1="\n$PS1"

# fix current user auto logout
# ################################################################
#TMOUT=100
#export TMOUT=0

# apache2
# ################################################################
# [[ $TERM != "screen" ]] && sudo service apache2 start

# tmux
# ################################################################
# [[ $TERM != "screen" ]] && exec tmux
# if [ -z "$TMUX" ] && ! grep -q Microsoft /proc/version; then
#     tmux attach -t default || tmux new -s default
# fi

# composer
# ################################################################
# COMPOSER_HOME=$HOME/.composer
# export COMPOSER_HOME=$HOME/.composer
export PATH=$PATH:$HOME/bin:$HOME/.composer/vendor/bin
if [ -d $HOME/.config/composer ]; then
    export PATH=$PATH:$HOME/.config/composer/vendor/bin
elif [ -d $HOME/.composer ]; then
    export PATH=$PATH:$HOME/.composer/vendor/bin
fi

# completion magerun2
# ################################################################
# https://raw.githubusercontent.com/netz98/n98-magerun2/develop/res/autocompletion/bash/n98-magerun2.phar.bash
if ! shopt -oq posix; then
    if [[ -f /var/www/base/bash/completion/magerun2.sh ]]; then
        . /var/www/base/bash/completion/magerun2.sh
    elif [[ -f $HOME/.completion/magerun2.sh ]]; then
        . $HOME/.completion/magerun2.sh
    fi
fi

# completion magerun
# ################################################################
# https://raw.githubusercontent.com/netz98/n98-magerun/develop/res/autocompletion/bash/n98-magerun.phar.bash
if ! shopt -oq posix; then
    if [[ -f /var/www/base/bash/completion/magerun.sh ]]; then
        . /var/www/base/bash/completion/magerun.sh
    elif [[ -f $HOME/.completion/magerun.sh ]]; then
        . $HOME/.completion/magerun.sh
    fi
fi

# bash completion for the `wp` command
# ################################################################
if ! shopt -oq posix; then
    if [[ -f /var/www/base/bash/completion/wp.sh ]]; then
        . /var/www/base/bash/completion/wp.sh
    elif [[ -f $HOME/.completion/wp.sh ]]; then
        . $HOME/.completion/wp.sh
    fi
fi

# bash completion for the `angular cli` command
# ################################################################
if ! shopt -oq posix; then
    if [[ -f /var/www/base/bash/completion/angular2.sh ]]; then
        . /var/www/base/bash/completion/angular2.sh
    elif [[ -f $HOME/.completion/angular2.sh ]]; then
        . $HOME/.completion/angular2.sh
    fi
fi

if [[ -d "/var/www/base/bash" ]]; then
    if [ "$(whoami)" = "ductn" ]; then
        chmod +x /var/www/base/bash/*
    fi
    PATH="$PATH:/var/www/base/bash"
fi

if [[ -d "/opt/mssql-tools/bin" ]]; then
    PATH="$PATH:/opt/mssql-tools/bin"
fi

# SSH AGENT autostart
# ################################################################
SSH_ENV="$HOME/.ssh/environment"

function start_agent() {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' >"${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" >/dev/null
    /usr/bin/ssh-add
}

# Source SSH settings, if applicable

if [[ -f "${SSH_ENV}" ]]; then
    . "${SSH_ENV}" >/dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ >/dev/null || {
        start_agent
    }
else
    start_agent
fi

# reload
#alias ductn_personal="/var/www/base/bash/personal.sh"
# alias ductn_tci="
# ductn_personal
# git config user.name lucas
# git config user.email lucas.ng@twentyci.asia
# "
