#!/usr/bin/env bash

# start symbol
# ################################################################
PS1="\n$PS1\n$ "

# apache2
# ################################################################
[[ $TERM != "screen" ]] && sudo service apache2 start

# tmux
# ################################################################
[[ $TERM != "screen" ]] && exec tmux

# bash alias for magento2
# ################################################################
alias m2rmgen="magerun2 generation:flush"
alias m2s="rm -rf var/view_preprocessed/* pub/static/frontend/* pub/static/adminhtml/* pub/static/_requirejs/*"

# cache
alias m2f="magerun2 cache:flush && magerun2 cache:clean"
alias m2c="m2f && rm -rf var/cache/* var/page_cache/* var/tmp/*"
alias m2up="m2c && magerun2 setup:upgrade"

# index
alias m2r="magerun2 indexer:reindex"

# permision
WEBSERVER_GROUP="www-data"
alias m2fixgroup="sudo usermod -aG $WEBSERVER_GROUP `whoami`"
alias m2perm="m2ch && chattr -i . && chown -R :$WEBSERVER_GROUP . && chmod u+x bin/magento"
alias m2ch_dir="find var pub/static pub/media app/etc -type d -print0 -printf '\r\n' -exec chmod g+ws {} \;"
alias m2ch_file="find var pub/static pub/media app/etc -type f -print0 -printf '\r\n' -exec chmod g+w {} \;"
alias m2ch="m2ch_dir && m2ch_file"

# grunt
alias m2grunt="m2up && grunt exec:all && grunt watch"

# bash completion for the `wp` command
# ################################################################
alias wpinstall="curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && sudo mv wp-cli.phar /usr/local/bin/wp"
_wp_complete() {
    local OLD_IFS="$IFS"
    local cur=${COMP_WORDS[COMP_CWORD]}

    IFS=$'\n';  # want to preserve spaces at the end
    local opts="$(wp cli completions --line="$COMP_LINE" --point="$COMP_POINT")"

    if [[ "$opts" =~ \<file\>\s* ]]
    then
        COMPREPLY=( $(compgen -f -- $cur) )
    elif [[ $opts = "" ]]
    then
        COMPREPLY=( $(compgen -f -- $cur) )
    else
        COMPREPLY=( ${opts[*]} )
    fi

    IFS="$OLD_IFS"
    return 0
}
complete -o nospace -F _wp_complete wp
