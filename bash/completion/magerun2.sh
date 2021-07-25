#!/bin/bash
# Installation:
#  Copy to /etc/bash_completion.d/n98-magerun.phar
# or
#  Append to ~/.bash_completion
# open new or restart existing shell session

alias m2setupcli="curl -O https://files.magerun.net/n98-magerun2.phar && chmod +x n98-magerun2.phar && mkdir -p ~/bin && mv n98-magerun2.phar ~/bin/magerun2"
# alias m2setupcli="curl -O https://files.magerun.net/n98-magerun2.phar && chmod +x n98-magerun2.phar && sudo mv n98-magerun2.phar /usr/local/bin/magerun2"

_magerun2()
{
    local cur script coms opts com
    COMPREPLY=()
    _get_comp_words_by_ref -n : cur words

    # for an alias, get the real script behind it
    if [[ $(type -t ${words[0]}) == "alias" ]]; then
        script=$(alias ${words[0]} | sed -E "s/alias ${words[0]}='(.*)'/\1/")
    else
        script=${words[0]}
    fi

    # lookup for command
    for word in ${words[@]:1}; do
        if [[ $word != -* ]]; then
            com=$word
            break
        fi
    done

    # completing for an option
    if [[ ${cur} == --* ]] ; then
        opts="--help --quiet --verbose --version --ansi --no-ansi --no-interaction --root-dir --skip-config --skip-root-check --skip-core-commands --skip-magento-compatibility-check"

        case "$com" in

            help)
            opts="${opts} --format --raw"
            ;;

            install)
            opts="${opts} --magentoVersion --magentoVersionByName --installationFolder --dbHost --dbUser --dbPass --dbName --dbPort --installSampleData --useDefaultConfigParams --baseUrl --replaceHtaccessFile --noDownload --only-download --forceUseDb --composer-use-same-php-binary"
            ;;

            list)
            opts="${opts} --raw --format"
            ;;

            open-browser)
            opts="${opts} "
            ;;

            script)
            opts="${opts} --define --stop-on-error"
            ;;

            self-update)
            opts="${opts} --unstable --dry-run"
            ;;

            shell)
            opts="${opts} "
            ;;

            admin:notifications)
            opts="${opts} --on --off"
            ;;

            admin:token:create)
            opts="${opts} --no-newline"
            ;;

            admin:user:change-password)
            opts="${opts} "
            ;;

            admin:user:change-status)
            opts="${opts} --activate --deactivate"
            ;;

            admin:user:delete)
            opts="${opts} --force"
            ;;

            admin:user:list)
            opts="${opts} --format"
            ;;

            cache:clean)
            opts="${opts} "
            ;;

            cache:disable)
            opts="${opts} --format"
            ;;

            cache:enable)
            opts="${opts} --format"
            ;;

            cache:flush)
            opts="${opts} "
            ;;

            cache:list)
            opts="${opts} --enabled --format"
            ;;

            cache:report)
            opts="${opts} --fpc --tags --mtime --filter-id --filter-tag --format"
            ;;

            cache:view)
            opts="${opts} --fpc --unserialize"
            ;;

            cms:block:toggle)
            opts="${opts} "
            ;;

            config:data:acl)
            opts="${opts} "
            ;;

            config:data:di)
            opts="${opts} --scope"
            ;;

            config:env:create)
            opts="${opts} "
            ;;

            config:env:set)
            opts="${opts} "
            ;;

            config:env:show)
            opts="${opts} --format"
            ;;

            config:store:delete)
            opts="${opts} --scope --scope-id --all"
            ;;

            config:store:get)
            opts="${opts} --scope --scope-id --decrypt --update-script --magerun-script --format"
            ;;

            config:store:set)
            opts="${opts} --scope --scope-id --encrypt --no-null"
            ;;

            customer:change-password)
            opts="${opts} "
            ;;

            customer:create)
            opts="${opts} --format"
            ;;

            customer:info)
            opts="${opts} "
            ;;

            customer:list)
            opts="${opts} --format"
            ;;

            customer:token:create)
            opts="${opts} --no-newline"
            ;;

            db:add-default-authorization-entries)
            opts="${opts} --connection"
            ;;

            db:console)
            opts="${opts} --use-mycli-instead-of-mysql --no-auto-rehash --connection"
            ;;

            db:create)
            opts="${opts} --connection"
            ;;

            db:drop)
            opts="${opts} --connection --tables --force"
            ;;

            db:dump)
            opts="${opts} --connection --add-time --compression --only-command --print-only-filename --dry-run --set-gtid-purged-off --no-single-transaction --human-readable --git-friendly --add-routines --no-tablespaces --stdout --strip --exclude --include --force --keep-column-statistics"
            ;;

            db:import)
            opts="${opts} --connection --compression --only-command --only-if-empty --optimize --drop --drop-tables --force --skip-authorization-entry-creation"
            ;;

            db:info)
            opts="${opts} --connection --format"
            ;;

            db:maintain:check-tables)
            opts="${opts} --type --repair --table --format"
            ;;

            db:query)
            opts="${opts} --connection --only-command"
            ;;

            db:status)
            opts="${opts} --connection --format --rounding --no-description"
            ;;

            db:variables)
            opts="${opts} --connection --format --rounding --no-description"
            ;;

            design:demo-notice)
            opts="${opts} --on --off --global"
            ;;

            dev:asset:clear)
            opts="${opts} --theme"
            ;;

            dev:console)
            opts="${opts} --area"
            ;;

            dev:module:create)
            opts="${opts} --minimal --add-blocks --add-helpers --add-models --add-setup --add-all --enable --modman --add-readme --add-composer --add-strict-types --author-name --author-email --description"
            ;;

            dev:module:list)
            opts="${opts} --vendor --format"
            ;;

            dev:module:observer:list)
            opts="${opts} --format --sort"
            ;;

            dev:report:count)
            opts="${opts} "
            ;;

            dev:symlinks)
            opts="${opts} --on --off --global"
            ;;

            dev:template-hints)
            opts="${opts} --on --off"
            ;;

            dev:template-hints-blocks)
            opts="${opts} --on --off"
            ;;

            dev:theme:list)
            opts="${opts} --format"
            ;;

            eav:attribute:list)
            opts="${opts} --add-source --add-backend --filter-type --format"
            ;;

            eav:attribute:remove)
            opts="${opts} "
            ;;

            eav:attribute:view)
            opts="${opts} --format"
            ;;

            generation:flush)
            opts="${opts} "
            ;;

            index:list)
            opts="${opts} --format"
            ;;

            index:trigger:recreate)
            opts="${opts} "
            ;;

            integration:create)
            opts="${opts} --consumer-key --consumer-secret --access-token --access-token-secret --resource"
            ;;

            integration:delete)
            opts="${opts} "
            ;;

            integration:list)
            opts="${opts} --format"
            ;;

            integration:show)
            opts="${opts} "
            ;;

            media:dump)
            opts="${opts} --strip"
            ;;

            script:repo:list)
            opts="${opts} --format"
            ;;

            script:repo:run)
            opts="${opts} --define --stop-on-error"
            ;;

            search:engine:list)
            opts="${opts} --format"
            ;;

            sys:check)
            opts="${opts} --format"
            ;;

            sys:cron:history)
            opts="${opts} --timezone --format"
            ;;

            sys:cron:list)
            opts="${opts} --format"
            ;;

            sys:cron:run)
            opts="${opts} "
            ;;

            sys:cron:schedule)
            opts="${opts} "
            ;;

            sys:info)
            opts="${opts} --format"
            ;;

            sys:maintenance)
            opts="${opts} --on --off"
            ;;

            sys:setup:change-version)
            opts="${opts} "
            ;;

            sys:setup:compare-versions)
            opts="${opts} --ignore-data --log-junit --format"
            ;;

            sys:setup:downgrade-versions)
            opts="${opts} --dry-run"
            ;;

            sys:store:config:base-url:list)
            opts="${opts} --format"
            ;;

            sys:store:list)
            opts="${opts} --format"
            ;;

            sys:url:list)
            opts="${opts} --add-categories --add-products --add-cmspages --add-all"
            ;;

            sys:website:list)
            opts="${opts} --format"
            ;;

        esac

        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        __ltrim_colon_completions "$cur"

        return 0;
    fi

    # completing for a command
    if [[ $cur == $com ]]; then
        coms="help install list open-browser script self-update shell admin:notifications admin:token:create admin:user:change-password admin:user:change-status admin:user:delete admin:user:list cache:clean cache:disable cache:enable cache:flush cache:list cache:report cache:view cms:block:toggle config:data:acl config:data:di config:env:create config:env:set config:env:show config:store:delete config:store:get config:store:set customer:change-password customer:create customer:info customer:list customer:token:create db:add-default-authorization-entries db:console db:create db:drop db:dump db:import db:info db:maintain:check-tables db:query db:status db:variables design:demo-notice dev:asset:clear dev:console dev:module:create dev:module:list dev:module:observer:list dev:report:count dev:symlinks dev:template-hints dev:template-hints-blocks dev:theme:list eav:attribute:list eav:attribute:remove eav:attribute:view generation:flush index:list index:trigger:recreate integration:create integration:delete integration:list integration:show media:dump script:repo:list script:repo:run search:engine:list sys:check sys:cron:history sys:cron:list sys:cron:run sys:cron:schedule sys:info sys:maintenance sys:setup:change-version sys:setup:compare-versions sys:setup:downgrade-versions sys:store:config:base-url:list sys:store:list sys:url:list sys:website:list"

        COMPREPLY=($(compgen -W "${coms}" -- ${cur}))
        __ltrim_colon_completions "$cur"

        return 0
    fi
}

complete -o default -F _magerun2 magerun2.phar n98-magerun2 magerun2
