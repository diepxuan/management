#!/usr/bin/env bash

# install to vps
# ################################################################
# cat .bash_aliases | ssh evolveretail.twtools "cat > $HOME/.bash_aliases"

# start symbol
# ################################################################
PS1="\n$PS1\n$ "

# fix current user auto logout
# ################################################################
#TMOUT=100
#export TMOUT=0

# apache2
# ################################################################
# [[ $TERM != "screen" ]] && sudo service apache2 start

# tmux
# ################################################################
[[ $TERM != "screen" ]] && exec tmux

# SSH AGENT autostart
# ################################################################
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [[ -f "${SSH_ENV}" ]]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

# composer
# ################################################################
# COMPOSER_HOME=$HOME/.composer
# export COMPOSER_HOME=$HOME/.composer
export PATH=$PATH:$HOME/bin:$HOME/.composer/vendor/bin
if [ -d $HOME/.config/composer ]; then
    export PATH=$PATH:$HOME/.config/composer/vendor/bin
elif [ -d $HOME/.composer ]; then
    export PATH=$PATH:$HOME/.composer/vendor/bin
fi

# bash alias for magento2
# ################################################################

# permision
WEBSERVER_GROUP="www-data"
alias m2ch="
_m2ch() {
    chmod -R g+w \${1}
    chmod g+ws \${1}
}

_m2ch app/etc
_m2ch vendor
_m2ch generated
_m2ch generation
_m2ch generation/code

_m2ch pub/static
_m2ch pub/media

_m2ch var
_m2ch var/log
_m2ch var/cache
_m2ch var/page_cache
_m2ch var/generation
_m2ch var/view_preprocessed
_m2ch var/tmp

_m2ch wp/wp-content/themes

unset -f _m2ch

# find var vendor pub/static pub/media app/etc -type f -print0 -printf '\r\n' -exec chmod g+w {} \;
# find var vendor pub/static pub/media app/etc -type d -print0 -printf '\r\n' -exec chmod g+ws {} \;
"

alias m2group="sudo usermod -aG $WEBSERVER_GROUP `whoami`"
alias m2urn="bin/magento dev:urn-catalog:generate .idea/misc.xml"

alias m2perm="
sudo chown -R `whoami`:$WEBSERVER_GROUP .
chmod u+x bin/magento
m2ch
"

# clean
alias m2rmgen="
find generated generated/code generation generation/code var/generation -maxdepth 1 -mindepth 1 -type d -not -name 'Magento' -not -name 'Composer' -not -name 'Symfony' -print0 -printf '\r\n' -exec rm -rf {} \;
magerun2 generation:flush"

alias m2static="
sudo rm -rf var/view_preprocessed/* pub/static/frontend/* pub/static/adminhtml/* pub/static/_requirejs/*
magerun2 dev:asset:clear"

alias m2cache="
sudo rm -rf var/cache/* var/page_cache/* var/tmp/* var/generation/* var/di/*
magerun2 cache:clean
magerun2 cache:flush"

# index
alias m2index="magerun2 indexer:reindex"

# grunt
alias m2grunt="
m2rmgen
m2static
m2cache
# bin/magento setup:upgrade
grunt exec:all
m2perm
grunt watch"

# setup
alias m2up="
m2perm
m2rmgen
m2static
m2cache
bin/magento setup:upgrade
m2perm"

alias m2config="
m2perm
magerun2 module:enable --all
magerun2 setup:di:compile
m2up"

alias m2setting="_m2setting() {
magerun2 config:store:set admin/security/admin_account_sharing   1
magerun2 config:store:set admin/security/use_form_key            0
magerun2 config:store:set admin/startup/page                     dashboard

magerun2 config:store:set customer/startup/redirect_dashboard    0

magerun2 config:store:set web/seo/use_rewrites                   1
magerun2 config:store:set web/session/use_frontend_sid           0
magerun2 config:store:set web/url/redirect_to_base               1

magerun2 config:store:set web/browser_capabilities/local_storage 1

magerun2 config:store:set web/secure/use_in_frontend             1
magerun2 config:store:set web/secure/use_in_adminhtml            1
magerun2 config:store:set web/secure/enable_hsts                 1
magerun2 config:store:set web/secure/enable_upgrade_insecure     1

magerun2 config:store:set admin/autologin/enable                 1
magerun2 config:store:set admin/autologin/username               admin

magerun2 config:store:set system/smtp/active                     1
magerun2 config:store:set system/smtp/smtphost                   smtp.zoho.com
magerun2 config:store:set system/smtp/username                   admin@diepxuan.com
magerun2 config:store:set system/smtp/password                   fbJdfF2xsKd5NSrv

if [ ! -z \$1 ]; then
    magerun2 config:store:set web/unsecure/base_url         http://\$1/
    magerun2 config:store:set web/secure/base_url           https://\$1/
    magerun2 config:store:set web/cookie/cookie_domain      \$1
fi

magerun2 admin:notifications --off

m2cache

unset -f _m2setting
}; _m2setting"

alias m2developer="
composer -vvv require --dev diepxuan/module-email
m2perm
m2rmgen
m2static
m2cache

magerun2 maintenance:enable
magerun2 deploy:mode:set developer
magerun2 module:enable --all
bin/magento setup:upgrade
magerun2 setup:di:compile
magerun2 maintenance:disable

m2cache
m2perm
"

# solr
alias m2delsolr="_m2delsolr() {
    sudo su solr -c \"/opt/solr/bin/solr delete -c \${1}\"
    unset -f _m2delsolr
}; _m2delsolr"
alias m2addsolr="_m2fixsolr() {
    sudo su solr -c \"/opt/solr/bin/solr delete -c \${1}\"
    sudo su solr -c \"/opt/solr/bin/solr create -c \${1}\"
    cat vendor/partsbx/core/src/module-partsbx-solr/conf/managed-schema | sudo su solr -c \"tee /var/solr/data/\${1}\/conf/managed-schema\"
    sudo service solr restart
    unset -f _m2fixsolr
}; _m2fixsolr"

# log
alias m2logenable="bin/magento dev:query-log:enable"
alias m2logdisable="bin/magento dev:query-log:disable"

# template debug
alias m2tempdebugenable="
magerun2 dev:template-hints-blocks --on
magerun2 dev:template-hints --on
"
alias m2tempdebugdisable="
magerun2 dev:template-hints-blocks --off
magerun2 dev:template-hints --off
"

# completion magerun2
# ################################################################
# https://raw.githubusercontent.com/netz98/n98-magerun2/develop/res/autocompletion/bash/n98-magerun2.phar.bash
if ! shopt -oq posix; then
    if [[ -f /var/www/base/bash/completion/magerun2.sh ]]; then
        . /var/www/base/bash/completion/magerun2.sh
    elif [[ -f $HOME/.completion/magerun2.sh ]]; then
        . $HOME/.completion/magerun2.sh
    fi
fi

# completion magerun
# ################################################################
# https://raw.githubusercontent.com/netz98/n98-magerun/develop/res/autocompletion/bash/n98-magerun.phar.bash
if ! shopt -oq posix; then
    if [[ -f /var/www/base/bash/completion/magerun.sh ]]; then
        . /var/www/base/bash/completion/magerun.sh
    elif [[ -f $HOME/.completion/magerun.sh ]]; then
        . $HOME/.completion/magerun.sh
    fi
fi

# bash completion for the `wp` command
# ################################################################
if ! shopt -oq posix; then
    if [[ -f /var/www/base/bash/completion/wp.sh ]]; then
        . /var/www/base/bash/completion/wp.sh
    elif [[ -f $HOME/.completion/wp.sh ]]; then
        . $HOME/.completion/wp.sh
    fi
fi

# bash completion for the `angular cli` command
# ################################################################
if ! shopt -oq posix; then
    if [[ -f /var/www/base/bash/completion/angular2.sh ]]; then
        . /var/www/base/bash/completion/angular2.sh
    elif [[ -f $HOME/.completion/angular2.sh ]]; then
        . $HOME/.completion/angular2.sh
    fi
fi

if [[ -d "/var/www/base/bash" ]] ; then
  PATH="$PATH:/var/www/base/bash"
fi

# reload
#alias ductn_personal="/var/www/base/bash/personal.sh"
# alias ductn_tci="
# ductn_personal
# git config user.name lucas
# git config user.email lucas.ng@twentyci.asia
# "
