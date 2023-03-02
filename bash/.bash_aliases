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

# composer PATH
# ################################################################
# COMPOSER_HOME=$HOME/.composer
# export COMPOSER_HOME=$HOME/.composer
export PATH=$PATH:$HOME/bin:$HOME/.composer/vendor/bin
[ -d $HOME/.config/composer ] && export PATH=$PATH:$HOME/.config/composer/vendor/bin
[ -d $HOME/.composer ] && export PATH=$PATH:$HOME/.composer/vendor/bin

# mssql-server PATH
# ################################################################
[ -d /opt/mssql-tools/bin/ ] && PATH="$PATH:/opt/mssql-tools/bin"
[ -d /opt/mssql/bin/ ] && PATH="$PATH:/opt/mssql/bin"

# ductn proccess PATH
# ################################################################
# if [[ -d "/var/www/base/bash" ]] && [ "$(whoami)" = "ductn" ]; then
#     chmod +x /var/www/base/bash/*
#     # PATH="$PATH:/var/www/base/bash"
# fi

# completion
# ################################################################
function _ductn_completion() {
    for _completion_path in $(ductn sys:completion); do
        . $_completion_path
    done
}
ductn do_no_thing 2>/dev/null && _ductn_completion

# SSH AGENT autostart
# ################################################################
SSH_ENV="$HOME/.ssh/environment"

function start_agent() {
    # echo "Initialising new SSH agent..."
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

# Missing command
# ################################################################
alias ll >/dev/null 2>&1 || alias ll="ls -alF"
alias cdd >/dev/null 2>&1 || alias cdd="cd $(ductn pwd)"

# reload
#alias ductn_personal="/var/www/base/bash/personal.sh"
# alias ductn_tci="
# ductn_personal
# git config user.name lucas
# git config user.email lucas.ng@twentyci.asia
# "
