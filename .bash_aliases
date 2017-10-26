# bash alias for magento2
WEBSERVER_GROUP="www-data"
alias m2="bin/magento"
alias m2rmgen="find var/generation -maxdepth 1 -mindepth 1 -type d -not -name 'Magento' -not -name 'Composer' -not -name 'Symfony' -print0 -printf '\r\n' -exec rm -rf {} \;"
alias m2f="m2 cache:flush && m2 cache:clean"
alias m2s="rm -rf var/view_preprocessed/* pub/static/frontend/* pub/static/adminhtml/* pub/static/_requirejs/*"
alias m2c="m2f && rm -rf var/cache/* var/page_cache/* var/tmp/*"
alias m2r="m2 indexer:reindex"
alias m2ch_dir="find var pub/static pub/media app/etc -type d -print0 -printf '\r\n' -exec chmod g+ws {} \;"
alias m2ch_file="find var pub/static pub/media app/etc -type f -print0 -printf '\r\n' -exec chmod g+w {} \;"
alias m2ch="m2ch_dir && m2ch_file"
alias m2up="m2 setup:upgrade && m2c"
alias m2fixgroup="sudo usermod -aG $WEBSERVER_GROUP `whoami`"
alias m2perm="m2ch && chattr -i . && chown -R :$WEBSERVER_GROUP . && chmod u+x bin/magento"

alias m2angular="nodemon --exec 'webpack' --watch app/code/Evolve/Angular/view/frontend/web/ts -e ts,js"
alias m2grunt="m2up; grunt exec:all; grunt watch;"

# bash completion for the `wp` command
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
