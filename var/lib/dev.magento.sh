#!/usr/bin/env bash
#!/bin/bash

WEBSERVER_GROUP="www-data"

_DUCTN_M2+=(ch)
_dev:ch() {
    _ch() {
        chmod -R g+w \${1}
        chmod g+ws \${1}
    }

    _ch app/etc
    _ch vendor
    _ch generated
    _ch generation
    _ch generation/code

    _ch pub/static
    _ch pub/media

    _ch var
    _ch var/log
    _ch var/cache
    _ch var/page_cache
    _ch var/generation
    _ch var/view_preprocessed
    _ch var/tmp

    _ch wp/wp-content/themes

    unset -f _ch

    # find var vendor pub/static pub/media app/etc -type f -print0 -printf '\r\n' -exec chmod g+w {} \;
    # find var vendor pub/static pub/media app/etc -type d -print0 -printf '\r\n' -exec chmod g+ws {} \;
}

_DUCTN_M2+=(group)
_dev:group() {
    usermod -aG $WEBSERVER_GROUP $(whoami)
}

_DUCTN_M2+=(urn)
_dev:urn() {
    bin/magento dev:urn-catalog:generate .idea/misc.xml
}

_DUCTN_M2+=(perm)
_dev:perm() {
    chown -R $(whoami):$WEBSERVER_GROUP .
    chmod u+x bin/magento
    _dev:ch
}

_DUCTN_M2+=(rmgen)
_dev:rmgen() {
    find generated generated/code generation generation/code var/generation -maxdepth 1 -mindepth 1 -type d -not -name 'Magento' -not -name 'Composer' -not -name 'Symfony' -print0 -printf '\r\n' -exec rm -rf {} \;
    magerun2 generation:flush
}

_DUCTN_M2+=(static)
_dev:static() {
    rm -rf var/view_preprocessed/* pub/static/frontend/* pub/static/adminhtml/* pub/static/_requirejs/*
    magerun2 dev:asset:clear
}

_DUCTN_M2+=(cache)
_dev:cache() {
    rm -rf var/cache/* var/page_cache/* var/tmp/* var/generation/* var/di/*
    magerun2 cache:clean
    magerun2 cache:flush
}

_DUCTN_M2+=(index)
_dev:index() {
    magerun2 indexer:reindex
}

_DUCTN_M2+=(grunt)
_dev:grunt() {
    _dev:rmgen
    _dev:static
    _dev:cache
    # bin/magento setup:upgrade
    grunt exec:all
    _dev:perm
    grunt watch
}

_DUCTN_M2+=(up)
_dev:up() {
    _dev:perm
    _dev:rmgen
    _dev:static
    _dev:cache
    bin/magento setup:upgrade
    _dev:perm
}

_DUCTN_M2+=(config)
_dev:config() {
    _dev:perm
    magerun2 module:enable --all
    magerun2 setup:di:compile
    _dev:ch
}

_DUCTN_M2+=(setting)
_dev:setting() {
    magerun2 config:store:set admin/security/admin_account_sharing 1
    magerun2 config:store:set admin/security/use_form_key 0
    magerun2 config:store:set admin/startup/page dashboard

    magerun2 config:store:set customer/startup/redirect_dashboard 0

    magerun2 config:store:set web/seo/use_rewrites 1
    magerun2 config:store:set web/session/use_frontend_sid 0
    magerun2 config:store:set web/url/redirect_to_base 1

    magerun2 config:store:set web/browser_capabilities/local_storage 1

    magerun2 config:store:set web/secure/use_in_frontend 1
    magerun2 config:store:set web/secure/use_in_adminhtml 1
    magerun2 config:store:set web/secure/enable_hsts 1
    magerun2 config:store:set web/secure/enable_upgrade_insecure 1

    magerun2 config:store:set admin/autologin/enable 1
    magerun2 config:store:set admin/autologin/username admin

    magerun2 config:store:set system/smtp/active 1
    magerun2 config:store:set system/smtp/smtphost smtp.zoho.com
    magerun2 config:store:set system/smtp/username admin@diepxuan.com
    magerun2 config:store:set system/smtp/password fbJdfF2xsKd5NSrv

    if [ ! -z \$1 ]; then
        magerun2 config:store:set web/unsecure/base_url http://\$1/
        magerun2 config:store:set web/secure/base_url https://\$1/
        magerun2 config:store:set web/cookie/cookie_domain \$1
    fi

    magerun2 admin:notifications --off

    _dev:cache

}

_DUCTN_M2+=(developer)
_dev:developer() {
    composer -vvv require --dev diepxuan/module-email
    _dev:perm
    _dev:rmgen
    _dev:static
    _dev:cache

    magerun2 maintenance:enable
    magerun2 deploy:mode:set developer
    magerun2 module:enable --all
    bin/magento setup:upgrade
    magerun2 setup:di:compile
    magerun2 maintenance:disable

    _dev:cache
    _dev:perm
}

_DUCTN_M2+=(delsolr)
_dev:delsolr() {
    sudo su solr -c \"/opt/solr/bin/solr delete -c \${1}\"
}

_DUCTN_M2+=(addsolr)
_dev:addsolr() {
    sudo su solr -c \"/opt/solr/bin/solr delete -c \${1}\"
    sudo su solr -c \"/opt/solr/bin/solr create -c \${1}\"
    cat vendor/partsbx/core/src/module-partsbx-solr/conf/managed-schema | sudo su solr -c \"tee /var/solr/data/\${1}\/conf/managed-schema\"
    sudo service solr restart
    unset -f _m2fixsolr
}

_DUCTN_M2+=(logenable)
_dev:logenable() {
    bin/magento dev:query-log:enable
}

_DUCTN_M2+=(logdisable)
_dev:logdisable() {
    bin/magento dev:query-log:disable
}

_DUCTN_M2+=(tempdebugenable)
_dev:tempdebugenable() {
    magerun2 dev:template-hints-blocks --on
    magerun2 dev:template-hints --on
}

_DUCTN_M2+=(tempdebugdisable)
_dev:tempdebugdisable() {
    magerun2 dev:template-hints-blocks --off
    magerun2 dev:template-hints --off
}

--m2() {
    "_dev:$*"
}

--m2:completion:commands() {
    echo "${_DUCTN_M2[*]}"
}
