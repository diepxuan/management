#!/usr/bin/env bash

# install to vps
# ################################################################
# cat .bash_aliases | ssh evolveretail.twtools "cat > ~/.bash_aliases"

# start symbol
# ################################################################
PS1="\n$PS1\n$ "

# apache2
# ################################################################
# [[ $TERM != "screen" ]] && sudo service apache2 start

# tmux
# ################################################################
[[ $TERM != "screen" ]] && exec tmux

# composer
# ################################################################
# COMPOSER_HOME=~/.composer
# export COMPOSER_HOME=~/.composer
export PATH=$PATH:$HOME/.composer/vendor/bin

# bash alias for magento2
# ################################################################

# permision
WEBSERVER_GROUP="www-data"
alias m2fixgroup="sudo usermod -aG $WEBSERVER_GROUP `whoami`"
alias m2ch_dir="find var vendor generated pub/static pub/media app/etc -type d -exec chmod u+w {} \;"
alias m2ch_file="find var generated vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;"
alias m2ch="m2ch_dir && m2ch_file"
alias m2perm="chattr -i . && sudo chown -R :$WEBSERVER_GROUP . && chmod u+x bin/magento && m2ch"

# clean
alias m2rmgen="magerun2 generation:flush"
# alias m2static="sudo rm -rf var/view_preprocessed/* pub/static/frontend/* pub/static/adminhtml/* pub/static/_requirejs/*"
alias m2static="magerun2 dev:asset:clear"

# cache
alias m2cache="magerun2 cache:flush && magerun2 cache:clean && sudo rm -rf var/cache/* var/page_cache/* var/tmp/*"
alias m2up="m2rmgen && m2cache && magerun2 setup:upgrade"

# index
alias m2index="magerun2 indexer:reindex"

# grunt
alias m2grunt="m2up && grunt exec:all && m2perm && grunt watch"

# setup
alias m2setupadmin="magerun2 admin:user:create --admin-user=gssadmin --admin-password=gss@123 --admin-email=admin@evolveretail.com --admin-firstname=Admin --admin-lastname=Gss"
alias m2fixconfig="magerun2 module:enable --all && m2up && m2perm"

# log
alias m2logenable="bin/magento dev:query-log:enable"
alias m2logdisable="bin/magento dev:query-log:disable"

# completion magerun2
# ################################################################
# https://raw.githubusercontent.com/netz98/n98-magerun2/develop/res/autocompletion/bash/n98-magerun2.phar.bash
# alias m2setupcli="curl -O https://files.magerun.net/n98-magerun2.phar && chmod +x n98-magerun2.phar && mkdir -p ~/bin && mv n98-magerun2.phar ~/bin/magerun2"
alias m2setupcli="curl -O https://files.magerun.net/n98-magerun2.phar && chmod +x n98-magerun2.phar && sudo mv n98-magerun2.phar /usr/local/bin/magerun2"
_n98-magerun2()
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
        opts="--help --quiet --verbose --version --ansi --no-ansi --no-interaction --root-dir --skip-config --skip-root-check --skip-core-commands"

        case "$com" in
            help)
            opts="${opts} --xml --format --raw"
            ;;
            install)
            opts="${opts} --magentoVersion --magentoVersionByName --installationFolder --dbHost --dbUser --dbPass --dbName --dbPort --installSampleData --useDefaultConfigParams --baseUrl --replaceHtaccessFile --noDownload --only-download --forceUseDb"
            ;;
            list)
            opts="${opts} --xml --raw --format"
            ;;
            open-browser)
            opts="${opts} "
            ;;
            script)
            opts="${opts} --define --stop-on-error"
            ;;
            shell)
            opts="${opts} "
            ;;
            admin:notifications)
            opts="${opts} --on --off"
            ;;
            admin:user:change-password)
            opts="${opts} "
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
            opts="${opts} "
            ;;
            catalog:product:attributes:cleanup)
            opts="${opts} "
            ;;
            config:data:acl)
            opts="${opts} "
            ;;
            config:data:di)
            opts="${opts} --scope"
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
            cron:run)
            opts="${opts} --group --bootstrap"
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
            db:console)
            opts="${opts} --connection"
            ;;
            db:create)
            opts="${opts} --connection"
            ;;
            db:drop)
            opts="${opts} --connection --tables --force"
            ;;
            db:dump)
            opts="${opts} --connection --add-time --compression --only-command --print-only-filename --dry-run --no-single-transaction --human-readable --add-routines --stdout --strip --exclude --force"
            ;;
            db:import)
            opts="${opts} --connection --compression --only-command --only-if-empty --optimize --drop --drop-tables"
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
            opts="${opts} "
            ;;
            dev:module:create)
            opts="${opts} --minimal --add-blocks --add-helpers --add-models --add-setup --add-all --enable --modman --add-readme --add-composer --author-name --author-email --description"
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
            dev:tests:run)
            opts="${opts} "
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
            indexer:set-mode)
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
            maintenance:allow-ips)
            opts="${opts} --none --magento-init-params"
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
            module:disable)
            opts="${opts} --force --all --clear-static-content --magento-init-params"
            ;;
            module:enable)
            opts="${opts} --force --all --clear-static-content --magento-init-params"
            ;;
            module:status)
            opts="${opts} --magento-init-params"
            ;;
            module:uninstall)
            opts="${opts} --remove-data --backup-code --backup-media --backup-db --clear-static-content --magento-init-params"
            ;;
            sampledata:deploy)
            opts="${opts} "
            ;;
            sampledata:remove)
            opts="${opts} "
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
            setup:backup)
            opts="${opts} --code --media --db --magento-init-params"
            ;;
            setup:config:set)
            opts="${opts} --backend-frontname --key --session-save --definition-format --db-host --db-name --db-user --db-engine --db-password --db-prefix --db-model --db-init-statements --skip-db-validation --http-cache-hosts --magento-init-params"
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
            opts="${opts} --backend-frontname --key --session-save --definition-format --db-host --db-name --db-user --db-engine --db-password --db-prefix --db-model --db-init-statements --skip-db-validation --http-cache-hosts --base-url --language --timezone --currency --use-rewrites --use-secure --base-url-secure --use-secure-admin --admin-use-security-key --admin-user --admin-password --admin-email --admin-firstname --admin-lastname --cleanup-database --sales-order-increment-prefix --use-sample-data --magento-init-params"
            ;;
            setup:performance:generate-fixtures)
            opts="${opts} --skip-reindex"
            ;;
            setup:rollback)
            opts="${opts} --code-file --media-file --db-file --magento-init-params"
            ;;
            setup:static-content:deploy)
            opts="${opts} --dry-run --no-javascript --no-css --no-less --no-images --no-fonts --no-html --no-misc --no-html-minify --theme --exclude-theme --language --exclude-language --area --exclude-area --jobs --symlink-locale"
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

        esac

        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        __ltrim_colon_completions "$cur"

        return 0;
    fi

    # completing for a command
    if [[ $cur == $com ]]; then
        coms="help install list open-browser script shell admin:notifications admin:user:change-password admin:user:create admin:user:delete admin:user:list admin:user:unlock app:config:dump cache:clean cache:disable cache:enable cache:flush cache:list cache:report cache:status cache:view catalog:images:resize catalog:product:attributes:cleanup config:data:acl config:data:di config:store:delete config:store:get config:store:set cron:run customer:create customer:hash:upgrade customer:info customer:list db:console db:create db:drop db:dump db:import db:info db:maintain:check-tables db:query db:status db:variables deploy:mode:set deploy:mode:show design:demo-notice dev:asset:clear dev:console dev:module:create dev:module:list dev:module:observer:list dev:report:count dev:source-theme:deploy dev:symlinks dev:template-hints dev:template-hints-blocks dev:tests:run dev:theme:list dev:urn-catalog:generate dev:xml:convert eav:attribute:list eav:attribute:remove eav:attribute:view generation:flush i18n:collect-phrases i18n:pack i18n:uninstall index:list index:trigger:recreate indexer:info indexer:reindex indexer:reset indexer:set-mode indexer:show-mode indexer:status info:adminuri info:backups:list info:currency:list info:dependencies:show-framework info:dependencies:show-modules info:dependencies:show-modules-circular info:language:list info:timezone:list maintenance:allow-ips maintenance:disable maintenance:enable maintenance:status media:dump module:disable module:enable module:status module:uninstall sampledata:deploy sampledata:remove sampledata:reset script:repo:list script:repo:run search:engine:list setup:backup setup:config:set setup:cron:run setup:db-data:upgrade setup:db-schema:upgrade setup:db:status setup:di:compile setup:install setup:performance:generate-fixtures setup:rollback setup:static-content:deploy setup:store-config:set setup:uninstall setup:upgrade sys:check sys:cron:history sys:cron:list sys:cron:run sys:cron:schedule sys:info sys:maintenance sys:setup:change-version sys:setup:compare-versions sys:setup:downgrade-versions sys:store:config:base-url:list sys:store:list sys:url:list sys:website:list theme:uninstall"

        COMPREPLY=($(compgen -W "${coms}" -- ${cur}))
        __ltrim_colon_completions "$cur"

        return 0
    fi
}
complete -o default -F _n98-magerun2 n98-magerun2.phar n98-magerun2 magerun2

# completion magerun
# ################################################################
# https://raw.githubusercontent.com/netz98/n98-magerun/develop/res/autocompletion/bash/n98-magerun.phar.bash
alias m1setupcli="curl -O https://files.magerun.net/n98-magerun.phar && chmod +x n98-magerun.phar && sudo mv n98-magerun.phar /usr/local/bin/magerun"
_n98-magerun()
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
        opts="--help --quiet --verbose --version --ansi --no-ansi --no-interaction --root-dir --skip-config --skip-root-check --developer-mode"

        case "$com" in
            help)
            opts="${opts} --xml --format --raw"
            ;;
            install)
            opts="${opts} --magentoVersion --magentoVersionByName --installationFolder --dbHost --dbUser --dbPass --dbName --dbPort --dbPrefix --installSampleData --useDefaultConfigParams --baseUrl --replaceHtaccessFile --noDownload --only-download --forceUseDb"
            ;;
            list)
            opts="${opts} --xml --raw --format"
            ;;
            open-browser)
            opts="${opts} "
            ;;
            script)
            opts="${opts} --define --stop-on-error"
            ;;
            shell)
            opts="${opts} "
            ;;
            uninstall)
            opts="${opts} --force --installationFolder"
            ;;
            admin:notifications)
            opts="${opts} --on --off"
            ;;
            admin:user:change-password)
            opts="${opts} "
            ;;
            admin:user:change-status)
            opts="${opts} --activate --deactivate"
            ;;
            admin:user:create)
            opts="${opts} "
            ;;
            admin:user:delete)
            opts="${opts} --force"
            ;;
            admin:user:list)
            opts="${opts} --format"
            ;;
            cache:clean)
            opts="${opts} --reinit --no-reinit"
            ;;
            cache:dir:flush)
            opts="${opts} "
            ;;
            cache:disable)
            opts="${opts} "
            ;;
            cache:enable)
            opts="${opts} "
            ;;
            cache:flush)
            opts="${opts} --reinit --no-reinit"
            ;;
            cache:list)
            opts="${opts} --format"
            ;;
            cache:report)
            opts="${opts} --tags --mtime --filter-id --filter-tag --fpc --format"
            ;;
            cache:view)
            opts="${opts} --unserialize --fpc"
            ;;
            category:create:dummy)
            opts="${opts} "
            ;;
            cms:block:toggle)
            opts="${opts} "
            ;;
            composer:diagnose)
            opts="${opts} "
            ;;
            composer:init)
            opts="${opts} --name --description --author --type --homepage --require --require-dev --stability --license --repository"
            ;;
            composer:install)
            opts="${opts} --prefer-source --prefer-dist --dry-run --dev --no-dev --no-custom-installers --no-autoloader --no-scripts --no-progress --no-suggest --optimize-autoloader --classmap-authoritative --apcu-autoloader --ignore-platform-reqs"
            ;;
            composer:require)
            opts="${opts} --dev --prefer-source --prefer-dist --no-progress --no-suggest --no-update --no-scripts --update-no-dev --update-with-dependencies --ignore-platform-reqs --prefer-stable --prefer-lowest --sort-packages --optimize-autoloader --classmap-authoritative --apcu-autoloader"
            ;;
            composer:search)
            opts="${opts} --only-name --type"
            ;;
            composer:update)
            opts="${opts} --prefer-source --prefer-dist --dry-run --dev --no-dev --lock --no-custom-installers --no-autoloader --no-scripts --no-progress --no-suggest --with-dependencies --optimize-autoloader --classmap-authoritative --apcu-autoloader --ignore-platform-reqs --prefer-stable --prefer-lowest --interactive --root-reqs"
            ;;
            composer:validate)
            opts="${opts} --no-check-all --no-check-lock --no-check-publish --with-dependencies --strict"
            ;;
            config:delete)
            opts="${opts} --scope --scope-id --force --all"
            ;;
            config:dump)
            opts="${opts} "
            ;;
            config:get)
            opts="${opts} --scope --scope-id --decrypt --update-script --magerun-script --format"
            ;;
            config:search)
            opts="${opts} "
            ;;
            config:set)
            opts="${opts} --scope --scope-id --encrypt --force --no-null"
            ;;
            customer:change-password)
            opts="${opts} "
            ;;
            customer:create)
            opts="${opts} --format"
            ;;
            customer:create:dummy)
            opts="${opts} --with-addresses --format"
            ;;
            customer:delete)
            opts="${opts} --all --force --range"
            ;;
            customer:info)
            opts="${opts} "
            ;;
            customer:list)
            opts="${opts} --format"
            ;;
            db:console)
            opts="${opts} --use-mycli-instead-of-mysql --no-auto-rehash"
            ;;
            db:create)
            opts="${opts} "
            ;;
            db:drop)
            opts="${opts} --tables --force"
            ;;
            db:dump)
            opts="${opts} --add-time --compression --dump-option --xml --hex-blob --only-command --print-only-filename --dry-run --no-single-transaction --human-readable --add-routines --stdout --strip --exclude --include --force"
            ;;
            db:import)
            opts="${opts} --compression --only-command --only-if-empty --optimize --drop --drop-tables"
            ;;
            db:info)
            opts="${opts} --format"
            ;;
            db:maintain:check-tables)
            opts="${opts} --type --repair --table --format"
            ;;
            db:query)
            opts="${opts} --only-command"
            ;;
            db:status)
            opts="${opts} --format --rounding --no-description"
            ;;
            db:variables)
            opts="${opts} --format --rounding --no-description"
            ;;
            design:demo-notice)
            opts="${opts} --on --off --global"
            ;;
            dev:class:lookup)
            opts="${opts} "
            ;;
            dev:code:model:method)
            opts="${opts} "
            ;;
            dev:console)
            opts="${opts} "
            ;;
            dev:email-template:usage)
            opts="${opts} --format"
            ;;
            dev:ide:phpstorm:meta)
            opts="${opts} --stdout"
            ;;
            dev:log)
            opts="${opts} --on --off --global"
            ;;
            dev:log:db)
            opts="${opts} --on --off"
            ;;
            dev:log:size)
            opts="${opts} --human"
            ;;
            dev:merge-css)
            opts="${opts} --on --off --global"
            ;;
            dev:merge-js)
            opts="${opts} --on --off --global"
            ;;
            dev:module:create)
            opts="${opts} --add-controllers --add-blocks --add-helpers --add-models --add-setup --add-all --modman --add-readme --add-composer --author-name --author-email --description"
            ;;
            dev:module:dependencies:from)
            opts="${opts} --all --format"
            ;;
            dev:module:dependencies:on)
            opts="${opts} --all --format"
            ;;
            dev:module:disable)
            opts="${opts} --codepool"
            ;;
            dev:module:enable)
            opts="${opts} --codepool"
            ;;
            dev:module:list)
            opts="${opts} --codepool --status --vendor --format"
            ;;
            dev:module:observer:list)
            opts="${opts} --format --sort"
            ;;
            dev:module:rewrite:conflicts)
            opts="${opts} --log-junit"
            ;;
            dev:module:rewrite:list)
            opts="${opts} --format"
            ;;
            dev:module:update)
            opts="${opts} --set-version --add-blocks --add-helpers --add-models --add-all --add-resource-model --add-routers --add-events --add-layout-updates --add-translate --add-default"
            ;;
            dev:profiler)
            opts="${opts} --on --off --global"
            ;;
            dev:report:count)
            opts="${opts} "
            ;;
            dev:setup:script:attribute)
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
            dev:theme:duplicates)
            opts="${opts} --log-junit"
            ;;
            dev:theme:info)
            opts="${opts} "
            ;;
            dev:theme:list)
            opts="${opts} --format"
            ;;
            dev:translate:admin)
            opts="${opts} --on --off"
            ;;
            dev:translate:export)
            opts="${opts} --store"
            ;;
            dev:translate:set)
            opts="${opts} "
            ;;
            dev:translate:shop)
            opts="${opts} --on --off"
            ;;
            eav:attribute:create-dummy-values)
            opts="${opts} "
            ;;
            eav:attribute:list)
            opts="${opts} --filter-type --add-source --add-backend --format"
            ;;
            eav:attribute:remove)
            opts="${opts} "
            ;;
            eav:attribute:view)
            opts="${opts} --format"
            ;;
            extension:download)
            opts="${opts} "
            ;;
            extension:install)
            opts="${opts} "
            ;;
            extension:list)
            opts="${opts} --format"
            ;;
            extension:upgrade)
            opts="${opts} "
            ;;
            extension:validate)
            opts="${opts} --skip-file --skip-hash --full-report --include-default"
            ;;
            index:list)
            opts="${opts} --format"
            ;;
            index:list:mview)
            opts="${opts} --format"
            ;;
            index:reindex)
            opts="${opts} "
            ;;
            index:reindex:all)
            opts="${opts} "
            ;;
            index:reindex:mview)
            opts="${opts} "
            ;;
            local-config:generate)
            opts="${opts} "
            ;;
            media:cache:image:clear)
            opts="${opts} "
            ;;
            media:cache:jscss:clear)
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
            opts="${opts} --ignore-data --log-junit --errors-only --format"
            ;;
            sys:setup:incremental)
            opts="${opts} --stop-on-error"
            ;;
            sys:setup:remove)
            opts="${opts} "
            ;;
            sys:setup:run)
            opts="${opts} --no-implicit-cache-flush"
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
        coms="help install list open-browser script shell uninstall admin:notifications admin:user:change-password admin:user:change-status admin:user:create admin:user:delete admin:user:list cache:clean cache:dir:flush cache:disable cache:enable cache:flush cache:list cache:report cache:view category:create:dummy cms:block:toggle composer:diagnose composer:init composer:install composer:require composer:search composer:update composer:validate config:delete config:dump config:get config:search config:set customer:change-password customer:create customer:create:dummy customer:delete customer:info customer:list db:console db:create db:drop db:dump db:import db:info db:maintain:check-tables db:query db:status db:variables design:demo-notice dev:class:lookup dev:code:model:method dev:console dev:email-template:usage dev:ide:phpstorm:meta dev:log dev:log:db dev:log:size dev:merge-css dev:merge-js dev:module:create dev:module:dependencies:from dev:module:dependencies:on dev:module:disable dev:module:enable dev:module:list dev:module:observer:list dev:module:rewrite:conflicts dev:module:rewrite:list dev:module:update dev:profiler dev:report:count dev:setup:script:attribute dev:symlinks dev:template-hints dev:template-hints-blocks dev:theme:duplicates dev:theme:info dev:theme:list dev:translate:admin dev:translate:export dev:translate:set dev:translate:shop eav:attribute:create-dummy-values eav:attribute:list eav:attribute:remove eav:attribute:view extension:download extension:install extension:list extension:upgrade extension:validate index:list index:list:mview index:reindex index:reindex:all index:reindex:mview local-config:generate media:cache:image:clear media:cache:jscss:clear media:dump script:repo:list script:repo:run sys:check sys:cron:history sys:cron:list sys:cron:run sys:info sys:maintenance sys:setup:change-version sys:setup:compare-versions sys:setup:incremental sys:setup:remove sys:setup:run sys:store:config:base-url:list sys:store:list sys:url:list sys:website:list"

        COMPREPLY=($(compgen -W "${coms}" -- ${cur}))
        __ltrim_colon_completions "$cur"

        return 0
    fi
}
complete -o default -F _n98-magerun n98-magerun.phar n98-magerun magerun

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
