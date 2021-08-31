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

            admin:user:create)
            opts="${opts} --admin-user --admin-password --admin-email --admin-firstname --admin-lastname --magento-init-params"
            ;;

            admin:user:delete)
            opts="${opts} --force"
            ;;

            admin:user:list)
            opts="${opts} --format"
            ;;

            admin:user:unlock)
            opts="${opts} "
            ;;

            app:config:dump)
            opts="${opts} "
            ;;

            app:config:import)
            opts="${opts} "
            ;;

            app:config:status)
            opts="${opts} "
            ;;

            braintree:migrate)
            opts="${opts} --host --dbname --username --password"
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

            cache:status)
            opts="${opts} --bootstrap"
            ;;

            cache:view)
            opts="${opts} --fpc --unserialize"
            ;;

            catalog:images:resize)
            opts="${opts} --async"
            ;;

            catalog:product:attributes:cleanup)
            opts="${opts} "
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

            config:sensitive:set)
            opts="${opts} --interactive --scope --scope-code"
            ;;

            config:set)
            opts="${opts} --scope --scope-code --lock-env --lock-config --lock"
            ;;

            config:show)
            opts="${opts} --scope --scope-code"
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

            cron:install)
            opts="${opts} --force --non-optional"
            ;;

            cron:remove)
            opts="${opts} "
            ;;

            cron:run)
            opts="${opts} --group --bootstrap"
            ;;

            customer:change-password)
            opts="${opts} "
            ;;

            customer:create)
            opts="${opts} --format"
            ;;

            customer:hash:upgrade)
            opts="${opts} "
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

            deploy:mode:set)
            opts="${opts} --skip-compilation"
            ;;

            deploy:mode:show)
            opts="${opts} "
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

            dev:di:info)
            opts="${opts} "
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

            dev:profiler:disable)
            opts="${opts} "
            ;;

            dev:profiler:enable)
            opts="${opts} "
            ;;

            dev:query-log:disable)
            opts="${opts} "
            ;;

            dev:query-log:enable)
            opts="${opts} --include-all-queries --query-time-threshold --include-call-stack"
            ;;

            dev:report:count)
            opts="${opts} "
            ;;

            dev:source-theme:deploy)
            opts="${opts} --type --locale --area --theme"
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

            dev:template-hints:disable)
            opts="${opts} "
            ;;

            dev:template-hints:enable)
            opts="${opts} "
            ;;

            dev:template-hints:status)
            opts="${opts} "
            ;;

            dev:tests:run)
            opts="${opts} --arguments"
            ;;

            dev:theme:list)
            opts="${opts} --format"
            ;;

            dev:urn-catalog:generate)
            opts="${opts} --ide"
            ;;

            dev:xml:convert)
            opts="${opts} --overwrite"
            ;;

            dotdigital:connector:automap)
            opts="${opts} "
            ;;

            dotdigital:connector:enable)
            opts="${opts} --username --password --automap-datafields --enable-syncs --remove-ip-restriction --enable-email-capture"
            ;;

            dotdigital:migrate)
            opts="${opts} "
            ;;

            dotdigital:sync)
            opts="${opts} --from"
            ;;

            downloadable:domains:add)
            opts="${opts} "
            ;;

            downloadable:domains:remove)
            opts="${opts} "
            ;;

            downloadable:domains:show)
            opts="${opts} "
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

            encryption:payment-data:update)
            opts="${opts} "
            ;;

            generation:flush)
            opts="${opts} "
            ;;

            i18n:collect-phrases)
            opts="${opts} --output --magento"
            ;;

            i18n:pack)
            opts="${opts} --mode --allow-duplicates"
            ;;

            i18n:uninstall)
            opts="${opts} --backup-code"
            ;;

            index:list)
            opts="${opts} --format"
            ;;

            index:trigger:recreate)
            opts="${opts} "
            ;;

            indexer:info)
            opts="${opts} "
            ;;

            indexer:reindex)
            opts="${opts} "
            ;;

            indexer:reset)
            opts="${opts} "
            ;;

            indexer:set-dimensions-mode)
            opts="${opts} "
            ;;

            indexer:set-mode)
            opts="${opts} "
            ;;

            indexer:show-dimensions-mode)
            opts="${opts} "
            ;;

            indexer:show-mode)
            opts="${opts} "
            ;;

            indexer:status)
            opts="${opts} "
            ;;

            info:adminuri)
            opts="${opts} "
            ;;

            info:backups:list)
            opts="${opts} "
            ;;

            info:currency:list)
            opts="${opts} "
            ;;

            info:dependencies:show-framework)
            opts="${opts} --output"
            ;;

            info:dependencies:show-modules)
            opts="${opts} --output"
            ;;

            info:dependencies:show-modules-circular)
            opts="${opts} --output"
            ;;

            info:language:list)
            opts="${opts} "
            ;;

            info:timezone:list)
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

            inventory:reservation:create-compensations)
            opts="${opts} --raw"
            ;;

            inventory:reservation:list-inconsistencies)
            opts="${opts} --complete-orders --incomplete-orders --bunch-size --raw"
            ;;

            inventory-geonames:import)
            opts="${opts} "
            ;;

            maintenance:allow-ips)
            opts="${opts} --none --add --magento-init-params"
            ;;

            maintenance:disable)
            opts="${opts} --ip --magento-init-params"
            ;;

            maintenance:enable)
            opts="${opts} --ip --magento-init-params"
            ;;

            maintenance:status)
            opts="${opts} --magento-init-params"
            ;;

            media:dump)
            opts="${opts} --strip"
            ;;

            media-content:sync)
            opts="${opts} "
            ;;

            media-gallery:sync)
            opts="${opts} "
            ;;

            module:config:status)
            opts="${opts} "
            ;;

            module:disable)
            opts="${opts} --force --all --clear-static-content --magento-init-params"
            ;;

            module:enable)
            opts="${opts} --force --all --clear-static-content --magento-init-params"
            ;;

            module:status)
            opts="${opts} --enabled --disabled --magento-init-params"
            ;;

            module:uninstall)
            opts="${opts} --remove-data --backup-code --backup-media --backup-db --non-composer --clear-static-content --magento-init-params"
            ;;

            newrelic:create:deploy-marker)
            opts="${opts} "
            ;;

            queue:consumers:list)
            opts="${opts} "
            ;;

            queue:consumers:start)
            opts="${opts} --max-messages --batch-size --area-code --single-thread --pid-file-path"
            ;;

            sampledata:deploy)
            opts="${opts} --no-update"
            ;;

            sampledata:remove)
            opts="${opts} --no-update"
            ;;

            sampledata:reset)
            opts="${opts} "
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

            security:recaptcha:disable-for-user-forgot-password)
            opts="${opts} "
            ;;

            security:recaptcha:disable-for-user-login)
            opts="${opts} "
            ;;

            setup:backup)
            opts="${opts} --code --media --db --magento-init-params"
            ;;

            setup:config:set)
            opts="${opts} --backend-frontname --enable-debug-logging --enable-syslog-logging --amqp-host --amqp-port --amqp-user --amqp-password --amqp-virtualhost --amqp-ssl --amqp-ssl-options --consumers-wait-for-messages --key --db-host --db-name --db-user --db-engine --db-password --db-prefix --db-model --db-init-statements --skip-db-validation --http-cache-hosts --db-ssl-key --db-ssl-cert --db-ssl-ca --db-ssl-verify --session-save --session-save-redis-host --session-save-redis-port --session-save-redis-password --session-save-redis-timeout --session-save-redis-persistent-id --session-save-redis-db --session-save-redis-compression-threshold --session-save-redis-compression-lib --session-save-redis-log-level --session-save-redis-max-concurrency --session-save-redis-break-after-frontend --session-save-redis-break-after-adminhtml --session-save-redis-first-lifetime --session-save-redis-bot-first-lifetime --session-save-redis-bot-lifetime --session-save-redis-disable-locking --session-save-redis-min-lifetime --session-save-redis-max-lifetime --session-save-redis-sentinel-master --session-save-redis-sentinel-servers --session-save-redis-sentinel-verify-master --session-save-redis-sentinel-connect-retires --cache-backend --cache-backend-redis-server --cache-backend-redis-db --cache-backend-redis-port --cache-backend-redis-password --cache-backend-redis-compress-data --cache-backend-redis-compression-lib --cache-id-prefix --allow-parallel-generation --page-cache --page-cache-redis-server --page-cache-redis-db --page-cache-redis-port --page-cache-redis-password --page-cache-redis-compress-data --page-cache-redis-compression-lib --page-cache-id-prefix --lock-provider --lock-db-prefix --lock-zookeeper-host --lock-zookeeper-path --lock-file-path --document-root-is-pub --magento-init-params"
            ;;

            setup:db-data:upgrade)
            opts="${opts} --magento-init-params"
            ;;

            setup:db-declaration:generate-patch)
            opts="${opts} --revertable --type"
            ;;

            setup:db-declaration:generate-whitelist)
            opts="${opts} --module-name"
            ;;

            setup:db-schema:upgrade)
            opts="${opts} --convert-old-scripts --magento-init-params"
            ;;

            setup:db:status)
            opts="${opts} --magento-init-params"
            ;;

            setup:di:compile)
            opts="${opts} "
            ;;

            setup:install)
            opts="${opts} --backend-frontname --enable-debug-logging --enable-syslog-logging --amqp-host --amqp-port --amqp-user --amqp-password --amqp-virtualhost --amqp-ssl --amqp-ssl-options --consumers-wait-for-messages --key --db-host --db-name --db-user --db-engine --db-password --db-prefix --db-model --db-init-statements --skip-db-validation --http-cache-hosts --db-ssl-key --db-ssl-cert --db-ssl-ca --db-ssl-verify --session-save --session-save-redis-host --session-save-redis-port --session-save-redis-password --session-save-redis-timeout --session-save-redis-persistent-id --session-save-redis-db --session-save-redis-compression-threshold --session-save-redis-compression-lib --session-save-redis-log-level --session-save-redis-max-concurrency --session-save-redis-break-after-frontend --session-save-redis-break-after-adminhtml --session-save-redis-first-lifetime --session-save-redis-bot-first-lifetime --session-save-redis-bot-lifetime --session-save-redis-disable-locking --session-save-redis-min-lifetime --session-save-redis-max-lifetime --session-save-redis-sentinel-master --session-save-redis-sentinel-servers --session-save-redis-sentinel-verify-master --session-save-redis-sentinel-connect-retires --cache-backend --cache-backend-redis-server --cache-backend-redis-db --cache-backend-redis-port --cache-backend-redis-password --cache-backend-redis-compress-data --cache-backend-redis-compression-lib --cache-id-prefix --allow-parallel-generation --page-cache --page-cache-redis-server --page-cache-redis-db --page-cache-redis-port --page-cache-redis-password --page-cache-redis-compress-data --page-cache-redis-compression-lib --page-cache-id-prefix --lock-provider --lock-db-prefix --lock-zookeeper-host --lock-zookeeper-path --lock-file-path --document-root-is-pub --base-url --language --timezone --currency --use-rewrites --use-secure --base-url-secure --use-secure-admin --admin-use-security-key --admin-user --admin-password --admin-email --admin-firstname --admin-lastname --search-engine --elasticsearch-host --elasticsearch-port --elasticsearch-enable-auth --elasticsearch-username --elasticsearch-password --elasticsearch-index-prefix --elasticsearch-timeout --cleanup-database --sales-order-increment-prefix --use-sample-data --enable-modules --disable-modules --convert-old-scripts --interactive --safe-mode --data-restore --dry-run --magento-init-params"
            ;;

            setup:performance:generate-fixtures)
            opts="${opts} --skip-reindex"
            ;;

            setup:rollback)
            opts="${opts} --code-file --media-file --db-file --magento-init-params"
            ;;

            setup:static-content:deploy)
            opts="${opts} --force --strategy --area --exclude-area --theme --exclude-theme --language --exclude-language --jobs --max-execution-time --symlink-locale --content-version --refresh-content-version-only --no-javascript --no-js-bundle --no-css --no-less --no-images --no-fonts --no-html --no-misc --no-html-minify"
            ;;

            setup:store-config:set)
            opts="${opts} --base-url --language --timezone --currency --use-rewrites --use-secure --base-url-secure --use-secure-admin --admin-use-security-key --magento-init-params"
            ;;

            setup:uninstall)
            opts="${opts} --magento-init-params"
            ;;

            setup:upgrade)
            opts="${opts} --keep-generated --convert-old-scripts --safe-mode --data-restore --dry-run --magento-init-params"
            ;;

            store:list)
            opts="${opts} "
            ;;

            store:website:list)
            opts="${opts} "
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

            theme:uninstall)
            opts="${opts} --backup-code --clear-static-content"
            ;;

            varnish:vcl:generate)
            opts="${opts} --access-list --backend-host --backend-port --export-version --grace-period --output-file"
            ;;

            yotpo:reset)
            opts="${opts} --entity"
            ;;

            yotpo:sync)
            opts="${opts} --entity --limit"
            ;;

            yotpo:update-metadata)
            opts="${opts} "
            ;;

        esac

        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        __ltrim_colon_completions "$cur"

        return 0;
    fi

    # completing for a command
    if [[ $cur == $com ]]; then
        coms="help install list open-browser script self-update shell admin:notifications admin:token:create admin:user:change-password admin:user:change-status admin:user:create admin:user:delete admin:user:list admin:user:unlock app:config:dump app:config:import app:config:status braintree:migrate cache:clean cache:disable cache:enable cache:flush cache:list cache:report cache:status cache:view catalog:images:resize catalog:product:attributes:cleanup cms:block:toggle config:data:acl config:data:di config:env:create config:env:set config:env:show config:sensitive:set config:set config:show config:store:delete config:store:get config:store:set cron:install cron:remove cron:run customer:change-password customer:create customer:hash:upgrade customer:info customer:list customer:token:create db:add-default-authorization-entries db:console db:create db:drop db:dump db:import db:info db:maintain:check-tables db:query db:status db:variables deploy:mode:set deploy:mode:show design:demo-notice dev:asset:clear dev:console dev:di:info dev:module:create dev:module:list dev:module:observer:list dev:profiler:disable dev:profiler:enable dev:query-log:disable dev:query-log:enable dev:report:count dev:source-theme:deploy dev:symlinks dev:template-hints dev:template-hints-blocks dev:template-hints:disable dev:template-hints:enable dev:template-hints:status dev:tests:run dev:theme:list dev:urn-catalog:generate dev:xml:convert dotdigital:connector:automap dotdigital:connector:enable dotdigital:migrate dotdigital:sync downloadable:domains:add downloadable:domains:remove downloadable:domains:show eav:attribute:list eav:attribute:remove eav:attribute:view encryption:payment-data:update generation:flush i18n:collect-phrases i18n:pack i18n:uninstall index:list index:trigger:recreate indexer:info indexer:reindex indexer:reset indexer:set-dimensions-mode indexer:set-mode indexer:show-dimensions-mode indexer:show-mode indexer:status info:adminuri info:backups:list info:currency:list info:dependencies:show-framework info:dependencies:show-modules info:dependencies:show-modules-circular info:language:list info:timezone:list integration:create integration:delete integration:list integration:show inventory:reservation:create-compensations inventory:reservation:list-inconsistencies inventory-geonames:import maintenance:allow-ips maintenance:disable maintenance:enable maintenance:status media:dump media-content:sync media-gallery:sync module:config:status module:disable module:enable module:status module:uninstall newrelic:create:deploy-marker queue:consumers:list queue:consumers:start sampledata:deploy sampledata:remove sampledata:reset script:repo:list script:repo:run search:engine:list security:recaptcha:disable-for-user-forgot-password security:recaptcha:disable-for-user-login setup:backup setup:config:set setup:db-data:upgrade setup:db-declaration:generate-patch setup:db-declaration:generate-whitelist setup:db-schema:upgrade setup:db:status setup:di:compile setup:install setup:performance:generate-fixtures setup:rollback setup:static-content:deploy setup:store-config:set setup:uninstall setup:upgrade store:list store:website:list sys:check sys:cron:history sys:cron:list sys:cron:run sys:cron:schedule sys:info sys:maintenance sys:setup:change-version sys:setup:compare-versions sys:setup:downgrade-versions sys:store:config:base-url:list sys:store:list sys:url:list sys:website:list theme:uninstall varnish:vcl:generate yotpo:reset yotpo:sync yotpo:update-metadata"

        COMPREPLY=($(compgen -W "${coms}" -- ${cur}))
        __ltrim_colon_completions "$cur"

        return 0
    fi
}

complete -o default -F _magerun2 magerun2.phar n98-magerun2 magerun2
