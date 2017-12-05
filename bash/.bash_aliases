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
if [ -f ~/public_html/code/bash/completion/magerun2.sh ]; then
    . ~/public_html/code/bash/completion/magerun2.sh
elif [ -f ~/completion/magerun2.sh ]; then
    . ~/completion/magerun2.sh
fi

# completion magerun
# ################################################################
# https://raw.githubusercontent.com/netz98/n98-magerun/develop/res/autocompletion/bash/n98-magerun.phar.bash
if [ -f ~/public_html/code/bash/completion/magerun.sh ]; then
    . ~/public_html/code/bash/completion/magerun.sh
elif [ -f ~/completion/magerun.sh ]; then
    . ~/completion/magerun.sh
fi

# bash completion for the `wp` command
# ################################################################
if [ -f ~/public_html/code/bash/completion/wp.sh ]; then
    . ~/public_html/code/bash/completion/wp.sh
elif [ -f ~/completion/wp.sh ]; then
    . ~/completion/wp.sh
fi

# bash completion for the `angular cli` command
# ################################################################
if [ -f ~/public_html/code/bash/completion/angular2.sh ]; then
    . ~/public_html/code/bash/completion/angular2.sh
elif [ -f ~/completion/angular2.sh ]; then
    . ~/completion/angular2.sh
fi
