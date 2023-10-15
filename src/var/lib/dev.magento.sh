#!/usr/bin/env bash
#!/bin/bash

WEBSERVER_GROUP="www-data"

_DUCTN_M2+=(ch)
_dev:m2:ch() {
    _ch() {
        chmod g+ws $*
        chmod -R g+w $*
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

    # find var vendor pub/static pub/media app/etc -type f -print0 -printf '\r\n' -exec chmod g+w {} \;
    # find var vendor pub/static pub/media app/etc -type d -print0 -printf '\r\n' -exec chmod g+ws {} \;
}

_DUCTN_M2+=(group)
_dev:m2:group() {
    usermod -aG $WEBSERVER_GROUP $(whoami)
}

_DUCTN_M2+=(urn)
_dev:m2:urn() {
    bin/magento dev:urn-catalog:generate .idea/misc.xml
}

_DUCTN_M2+=(perm)
_dev:m2:perm() {
    chown -R $(whoami):$WEBSERVER_GROUP .
    chmod u+x bin/magento
    _dev:m2:ch
}

_DUCTN_M2+=(rmgen)
_dev:m2:rmgen() {
    find generated generated/code generation generation/code var/generation -maxdepth 1 -mindepth 1 -type d -not -name 'Magento' -not -name 'Composer' -not -name 'Symfony' -print0 -printf '\r\n' -exec rm -rf {} \;
    magerun2 generation:flush
}

_DUCTN_M2+=(static)
_dev:m2:static() {
    rm -rf var/view_preprocessed/* pub/static/frontend/* pub/static/adminhtml/* pub/static/_requirejs/*
    magerun2 dev:asset:clear
}

_DUCTN_M2+=(cache)
_dev:m2:cache() {
    # rm -rf var/cache/* var/page_cache/* var/tmp/* var/generation/* var/di/*
    # magerun2 cache:clean
    magerun2 cache:flush
}

_DUCTN_M2+=(index)
_dev:m2:index() {
    magerun2 indexer:reindex
}

_DUCTN_M2+=(grunt)
_dev:m2:grunt() {
    _dev:m2:rmgen
    _dev:m2:static
    _dev:m2:cache
    # bin/magento setup:upgrade
    grunt exec:all
    _dev:m2:perm
    grunt watch
}

_DUCTN_M2+=(up)
_dev:m2:up() {
    # _dev:m2:perm
    # _dev:m2:rmgen
    # _dev:m2:static
    # _dev:m2:cache
    bin/magento setup:upgrade $@
    # _dev:m2:perm
}

_DUCTN_M2+=(elasticsearch)
_dev:m2:elasticsearch() {
    curl -XGET 'http://localhost:9200'
    curl -XGET 'localhost:9200/_cluster/health?pretty'
}

# https://gist.github.com/dominicsayers/8319752
_dev:m2:elasticsearch_install() {
    [[ --user:is_sudoer ]] || return

    if [[ $(--sys:apt:check elasticsearch) == 0 ]]; then
        wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
        # --sys:apt:install default-jdk
        # --sys:apt:install openjdk-8-jdk
        --sys:apt:install elasticsearch

        sudo systemctl daemon-reload
        sudo systemctl enable elasticsearch.service
        sudo systemctl start elasticsearch.service
    fi

    # sudo sed -i "s|.*xpack.security.enabled: .*|xpack.security.enabled: false|" /etc/elasticsearch/elasticsearch.yml

    # /etc/security/limits.conf
    # elasticsearch hard memlock 128000
    local match=elasticsearch
    local value='elasticsearch hard memlock 128000'
    local file=/etc/security/limits.conf
    if [[ -f $file ]]; then
        [[ -n $(grep "$match" $file) ]] || sudo tee -a $value $file
        [[ -n $(grep "$match" $file) ]] && sudo sed -i "s|.*$match*|$value|" $file
    fi

    # /etc/default/elasticsearch
    # ES_HEAP_SIZE=128m
    # MAX_LOCKED_MEMORY=128000
    # ES_JAVA_OPTS=-server
    local values=('ES_HEAP_SIZE=128m' 'MAX_LOCKED_MEMORY=128000' 'ES_JAVA_OPTS=-server')
    file=/etc/default/elasticsearch

    if [[ -f $file ]]; then
        for value in ${values[@]}; do
            match=${value%=*}

            [[ -n $(grep "$match" $file) ]] || sudo tee -a $value $file
            [[ -n $(grep "$match" $file) ]] && sudo sed -i "s|.*$match*|$value|" $file
        done
    fi

    # /etc/elasticsearch/jvm.options
    # -Xms128m
    # -Xmx128m

    # elasticsearch 7.17
    # /etc/elasticsearch/elasticsearch.yml
    # network.host: 0.0.0.0
    # http.port: 9200
    # discovery.type: single-node
}

_DUCTN_M2+=(config)
_dev:m2:config() {
    _dev:m2:perm
    magerun2 module:enable --all
    magerun2 setup:di:compile
    _dev:m2:ch
}

_DUCTN_M2+=(setting)
_dev:m2:setting() {
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

    if [ ! -z $1 ]; then
        magerun2 config:store:set web/unsecure/base_url http://$1/
        magerun2 config:store:set web/secure/base_url https://$1/
        magerun2 config:store:set web/cookie/cookie_domain $1
    fi

    magerun2 admin:notifications --off

    _dev:m2:cache

}

_DUCTN_M2+=(developer)
_dev:m2:developer() {
    composer -vvv require --dev diepxuan/module-email
    _dev:m2:perm
    _dev:m2:rmgen
    _dev:m2:static
    _dev:m2:cache

    magerun2 maintenance:enable
    magerun2 deploy:mode:set developer
    magerun2 module:enable --all
    bin/magento setup:upgrade
    magerun2 setup:di:compile
    magerun2 maintenance:disable

    _dev:m2:cache
    _dev:m2:perm
}

_DUCTN_M2+=(delsolr)
_dev:m2:delsolr() {
    sudo su solr -c "/opt/solr/bin/solr delete -c ${1}"
}

_DUCTN_M2+=(addsolr)
_dev:m2:addsolr() {
    sudo su solr -c "/opt/solr/bin/solr delete -c ${1}"
    sudo su solr -c "/opt/solr/bin/solr create -c ${1}"
    cat vendor/partsbx/core/src/module-partsbx-solr/conf/managed-schema | sudo su solr -c "tee /var/solr/data/${1}\/conf/managed-schema"
    sudo service solr restart
    unset -f _m2fixsolr
}

_DUCTN_M2+=(logenable)
_dev:m2:logenable() {
    bin/magento dev:query-log:enable
}

_DUCTN_M2+=(logdisable)
_dev:m2:logdisable() {
    bin/magento dev:query-log:disable
}

_DUCTN_M2+=(tempdebugenable)
_dev:m2:tempdebugenable() {
    magerun2 dev:template-hints-blocks --on
    magerun2 dev:template-hints --on
}

_DUCTN_M2+=(tempdebugdisable)
_dev:m2:tempdebugdisable() {
    magerun2 dev:template-hints-blocks --off
    magerun2 dev:template-hints --off
}

_DUCTN_M2+=(install)
_dev:m2:install() {
    curl -O https://files.magerun.net/n98-magerun2.phar && chmod +x n98-magerun2.phar && sudo mv n98-magerun2.phar /usr/local/bin/magerun2
}

_dev:m2:completion() {
    symfony-autocomplete --shell=bash -- magerun2 | sed '1d ; $ s/$/.phar '"n98-magerun2 magerun2"'/' | sudo tee /etc/bash_completion.d/n98-magerun2
}

--m2() {
    [[ $(type -t _dev:m2:$*) == function ]] && _dev:m2:$*
    [[ ! $(type -t _dev:m2:$*) == function ]] && [[ -f bin/magento ]] && php bin/magento $*
}

--m2:completion:commands() {
    echo "${_DUCTN_M2[*]}"
}