#!/usr/bin/env bash

# install to vps
# ################################################################
# cat .bash_aliases | ssh evolveretail.twtools "cat > $HOME/.bash_aliases"

# start symbol
# ################################################################
PS1="\n$PS1\n$ "

# apache2
# ################################################################
# [[ $TERM != "screen" ]] && sudo service apache2 start

# tmux
# ################################################################
# [[ $TERM != "screen" ]] && exec tmux

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
alias m2ch_dir="find var vendor generated pub/static pub/media app/etc var/generation -type d -exec sudo chmod u+w {} \;"
alias m2ch_file="find var generated vendor pub/static pub/media app/etc var/generation -type f -exec sudo chmod u+w {} \;"
alias m2ch="
m2ch_dir
m2ch_file"

alias m2perm="
chattr -i .
sudo chown -R `whoami`:$WEBSERVER_GROUP .
chmod u+x bin/magento
"

# clean
alias m2rmgen="
find generation generation/code var/generation -maxdepth 1 -mindepth 1 -type d -not -name 'Magento' -not -name 'Composer' -not -name 'Symfony' -print0 -printf '\r\n' -exec rm -rf {} \;
magerun2 generation:flush"

alias m2static="
sudo rm -rf var/view_preprocessed/* pub/static/frontend/* pub/static/adminhtml/* pub/static/_requirejs/*
magerun2 dev:asset:clear"

# cache
alias m2cache="
sudo rm -rf var/cache/* var/page_cache/* var/tmp/* var/generation/* var/di/*
magerun2 cache:clean
magerun2 cache:flush"
alias m2up="
m2rmgen
m2static
m2cache
bin/magento setup:upgrade
m2perm"

# index
alias m2index="magerun2 indexer:reindex"

# grunt
alias m2grunt="
m2up
grunt exec:all
m2perm
grunt watch"

# setup
alias m2fixconfig="
m2perm
magerun2 deploy:mode:set developer
magerun2 module:enable --all
magerun2 setup:di:compile
m2up"

alias m2fixgroup="sudo usermod -aG $WEBSERVER_GROUP `whoami`"

alias m2fixsetting="
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
"

# deploy
alias m2deploy="
m2fixconfig
magerun2 deploy:mode:set developer
magerun2 setup:di:compile
magerun2 maintenance:disable
m2cache
m2perm
"

# log
alias m2logenable="bin/magento dev:query-log:enable"
alias m2logdisable="bin/magento dev:query-log:disable"

# completion magerun2
# ################################################################
# https://raw.githubusercontent.com/netz98/n98-magerun2/develop/res/autocompletion/bash/n98-magerun2.phar.bash
if [ -f /var/www/base/bash/completion/magerun2.sh ]; then
    . /var/www/base/bash/completion/magerun2.sh
elif [ -f $HOME/.completion/magerun2.sh ]; then
    . $HOME/.completion/magerun2.sh
fi

# completion magerun
# ################################################################
# https://raw.githubusercontent.com/netz98/n98-magerun/develop/res/autocompletion/bash/n98-magerun.phar.bash
if [ -f /var/www/base/bash/completion/magerun.sh ]; then
    . /var/www/base/bash/completion/magerun.sh
elif [ -f $HOME/.completion/magerun.sh ]; then
    . $HOME/.completion/magerun.sh
fi

# bash completion for the `wp` command
# ################################################################
if [ -f /var/www/base/bash/completion/wp.sh ]; then
    . /var/www/base/bash/completion/wp.sh
elif [ -f $HOME/.completion/wp.sh ]; then
    . $HOME/.completion/wp.sh
fi

# bash completion for the `angular cli` command
# ################################################################
if [ -f /var/www/base/bash/completion/angular2.sh ]; then
    . /var/www/base/bash/completion/angular2.sh
elif [ -f $HOME/.completion/angular2.sh ]; then
    . $HOME/.completion/angular2.sh
fi
