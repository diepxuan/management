#!/bin/bash
# Installation:
#  Append to ~/.bash_completion
# open new or restart existing shell session

_ductn() {
    local cur script coms opts com
    COMPREPLY=()
    _get_comp_words_by_ref -n : cur words

    # lookup for command
    for word in ${words[@]:1}; do
        if [[ $word != -* ]]; then
            com=$word
            break
        fi
    done

    # completing for an option
    if [[ ${cur} == --* ]]; then
        # opts="--help --quiet --verbose --version --ansi --no-ansi --no-interaction --root-dir --skip-config --skip-root-check --skip-core-commands"
        opts="--help"

        case "$com" in

        apt:fix)
            opts="${opts}"
            ;;

        cron)
            opts="${opts} --service --update"
            ;;

        git)
            opts="${opts} --configure"
            ;;

        ssl)
            opts="${opts} --install --configure --pull --push"
            ;;

        ssh:install)
            opts="${opts}"
            ;;

        httpd:install)
            opts="${opts}"
            ;;

        httpd:config)
            opts="${opts}"
            ;;

        mysql:ssl:enable)
            opts="${opts}"
            ;;

        ddns:update)
            opts="${opts}"
            ;;

        cron:update)
            opts="${opts}"
            ;;

        cron:service)
            opts="${opts}"
            ;;

        sys:ddns-allow)
            opts="${opts}"
            ;;

        user:new)
            opts="${opts} -u"
            ;;

        self-update)
            opts="${opts} "
            ;;

        log:watch)
            opts="${opts} "
            ;;

        log:cleanup)
            opts="${opts} "
            ;;

        sqlsrv:php:install | mssql:php:install)
            opts="${opts} "
            ;;

        sqlsrv:php:enable | mssql:php:enable)
            opts="${opts} "
            ;;

        sqlsrv:install | mssql:install)
            opts="${opts} "
            ;;

        wsl:cli:install)
            opts="${opts} "
            ;;

        swap:remove | swap:install)
            opts="${opts} "
            ;;

        esac

        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        __ltrim_colon_completions "$cur"

        return 0
    fi

    # completing for a command
    if [[ $cur == $com ]]; then
        coms=("sys:ufw" "sys:hosts" "sys:init" "sys:selfupdate" "")

        coms+=("selfupdate" "self-update")
        coms+=("ssh:install")
        coms+=("wsl:cli:install")
        coms+=("sqlsrv:php:install" "mssql:php:install" "sqlsrv:php:enable" "mssql:php:enable" "sqlsrv:php:disable" "mssql:php:disable")
        coms+=("php:composer:install" "php:phpcsfixer:install")
        coms+=("sqlsrv:install" "mssql:install")
        coms+=("swap:remove" "swap:install")
        coms+=("cron:update" "cron:service" "cron:crontab:install")
        coms+=("ddns:getip" "ddns:update" "ddns:allow")
        coms+=("hosts:add" "hosts:remove" "hosts")
        coms+=("apt:fix" "git" "ssl" "self-update" "user:new" "httpd:install")
        coms+=("httpd:config" "mysql:ssl:enable" "ddns:update")
        coms+=("log:watch" "log:cleanup" "log:watch:service")
        coms+=("ufw:geoip:install" "ufw:geoip:update" "ufw:geoip:configuration" "ufw:geoip:allowCloudflare")
        coms+=("ufw:fail2ban:install" "ufw:fail2ban:configuration")
        coms+=("dns:update")

        separator=" "
        coms="$(printf "${separator}%s" "${coms[@]}")"
        coms="${coms:${#separator}}"

        COMPREPLY=($(compgen -W "${coms}" -- ${cur}))
        __ltrim_colon_completions "$cur"

        return 0
    fi
}

complete -o default -F _ductn ductn
