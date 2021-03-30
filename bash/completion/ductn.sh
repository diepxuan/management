#!/bin/bash
# Installation:
#  Append to ~/.bash_completion
# open new or restart existing shell session

_ductn()
{
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
    if [[ ${cur} == --* ]] ; then
        # opts="--help --quiet --verbose --version --ansi --no-ansi --no-interaction --root-dir --skip-config --skip-root-check --skip-core-commands"
        opts="--help"

        case "$com" in

            git)
            opts="${opts} --configure"
            ;;

            ssl)
            opts="${opts} --install --configure --pull --push"
            ;;

            ssh)
            opts="${opts} --install"
            ;;

            setup:backup)
            opts="${opts} --code --media --db --magento-init-params"
            ;;

            setup:config:set)
            opts="${opts} --backend-frontname --key --db-host --db-name --db-user --db-engine --db-password --db-prefix --db-model --db-init-statements --skip-db-validation --http-cache-hosts --session-save --session-save-redis-host --session-save-redis-port --session-save-redis-password --session-save-redis-timeout --session-save-redis-persistent-id --session-save-redis-db --session-save-redis-compression-threshold --session-save-redis-compression-lib --session-save-redis-log-level --session-save-redis-max-concurrency --session-save-redis-break-after-frontend --session-save-redis-break-after-adminhtml --session-save-redis-first-lifetime --session-save-redis-bot-first-lifetime --session-save-redis-bot-lifetime --session-save-redis-disable-locking --session-save-redis-min-lifetime --session-save-redis-max-lifetime --cache-backend --cache-backend-redis-server --cache-backend-redis-db --cache-backend-redis-port --page-cache --page-cache-redis-server --page-cache-redis-db --page-cache-redis-port --page-cache-redis-compress-data --magento-init-params"
            ;;

            setup:cron:run)
            opts="${opts} --magento-init-params"
            ;;

            setup:db-data:upgrade)
            opts="${opts} --magento-init-params"
            ;;

            setup:db-schema:upgrade)
            opts="${opts} --magento-init-params"
            ;;

            setup:db:status)
            opts="${opts} --magento-init-params"
            ;;

            setup:di:compile)
            opts="${opts} "
            ;;

            setup:install)
            opts="${opts} --backend-frontname --key --db-host --db-name --db-user --db-engine --db-password --db-prefix --db-model --db-init-statements --skip-db-validation --http-cache-hosts --session-save --session-save-redis-host --session-save-redis-port --session-save-redis-password --session-save-redis-timeout --session-save-redis-persistent-id --session-save-redis-db --session-save-redis-compression-threshold --session-save-redis-compression-lib --session-save-redis-log-level --session-save-redis-max-concurrency --session-save-redis-break-after-frontend --session-save-redis-break-after-adminhtml --session-save-redis-first-lifetime --session-save-redis-bot-first-lifetime --session-save-redis-bot-lifetime --session-save-redis-disable-locking --session-save-redis-min-lifetime --session-save-redis-max-lifetime --cache-backend --cache-backend-redis-server --cache-backend-redis-db --cache-backend-redis-port --page-cache --page-cache-redis-server --page-cache-redis-db --page-cache-redis-port --page-cache-redis-compress-data --base-url --language --timezone --currency --use-rewrites --use-secure --base-url-secure --use-secure-admin --admin-use-security-key --admin-user --admin-password --admin-email --admin-firstname --admin-lastname --cleanup-database --sales-order-increment-prefix --use-sample-data --interactive --magento-init-params"
            ;;

            setup:performance:generate-fixtures)
            opts="${opts} --skip-reindex"
            ;;

            setup:rollback)
            opts="${opts} --code-file --media-file --db-file --magento-init-params"
            ;;

            setup:static-content:deploy)
            opts="${opts} --force --strategy --area --exclude-area --theme --exclude-theme --language --exclude-language --jobs --symlink-locale --content-version --refresh-content-version-only --no-javascript --no-css --no-less --no-images --no-fonts --no-html --no-misc --no-html-minify"
            ;;

            setup:store-config:set)
            opts="${opts} --base-url --language --timezone --currency --use-rewrites --use-secure --base-url-secure --use-secure-admin --admin-use-security-key --magento-init-params"
            ;;

            setup:uninstall)
            opts="${opts} --magento-init-params"
            ;;

            setup:upgrade)
            opts="${opts} --keep-generated --magento-init-params"
            ;;

            store:list)
            opts="${opts} "
            ;;

            store:website:list)
            opts="${opts} "
            ;;

            sys:init)
            opts="${opts} --server --admin"
            ;;

            sys:init:install)
            opts="${opts} --server --admin"
            ;;

            sys:cron:install)
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

            theme:uninstall)
            opts="${opts} --backup-code --clear-static-content"
            ;;

            varnish:vcl:generate)
            opts="${opts} --access-list --backend-host --backend-port --export-version --grace-period --output-file"
            ;;

        esac

        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        __ltrim_colon_completions "$cur"

        return 0;
    fi

    # completing for a command
    if [[ $cur == $com ]]; then
        coms="git ssl ssh sys:init sys:init"

        COMPREPLY=($(compgen -W "${coms}" -- ${cur}))
        __ltrim_colon_completions "$cur"

        return 0
    fi
}

complete -o default -F _ductn ductn
