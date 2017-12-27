#!/usr/bin/env bash

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
