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
# [[ $TERM != "screen" ]] && exec tmux

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
alias m2ch_dir="find var vendor generated pub/static pub/media app/etc -type d -exec sudo chmod u+w {} \;"
alias m2ch_file="find var generated vendor pub/static pub/media app/etc -type f -exec sudo chmod u+w {} \;"
alias m2ch="m2ch_dir; m2ch_file"

if [[ $(uname -r | sed -n 's/.*\( *Microsoft *\).*/\1/p') == Microsoft ]]; then
    alias m2perm="chmod u+x bin/magento"
else
    alias m2perm="chattr -i .; sudo chown -R :$WEBSERVER_GROUP .; chmod u+x bin/magento"
fi

# clean
alias m2rmgen="magerun2 generation:flush; find var/generation -maxdepth 1 -mindepth 1 -type d -not -name 'Magento' -not -name 'Composer' -not -name 'Symfony' -print0 -printf '\r\n' -exec rm -rf {} \;"
alias m2static="magerun2 dev:asset:clear; sudo rm -rf var/view_preprocessed/* pub/static/frontend/* pub/static/adminhtml/* pub/static/_requirejs/*"

# cache
alias m2cache="magerun2 cache:flush; magerun2 cache:clean; sudo rm -rf var/cache/* var/page_cache/* var/tmp/* var/generation/* var/di/*"
# alias m2up="m2rmgen && m2static && m2cache && magerun2 setup:upgrade"
alias m2up="m2rmgen; m2static; m2cache; bin/magento setup:upgrade; m2perm"

# index
alias m2index="magerun2 indexer:reindex"

# grunt
alias m2grunt="m2up; grunt exec:all; m2perm; grunt watch"

# setup
alias m2fixconfig="magerun2 module:enable --all; m2up"
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

magerun2 config:store:set admin/autologin/enable                 1
magerun2 config:store:set admin/autologin/username               admin
"

# log
alias m2logenable="bin/magento dev:query-log:enable"
alias m2logdisable="bin/magento dev:query-log:disable"

# completion magerun2
# ################################################################
# https://raw.githubusercontent.com/netz98/n98-magerun2/develop/res/autocompletion/bash/n98-magerun2.phar.bash
if [ -f ~/public_html/code/bash/completion/magerun2.sh ]; then
    . ~/public_html/code/bash/completion/magerun2.sh
elif [ -f ~/.completion/magerun2.sh ]; then
    . ~/.completion/magerun2.sh
fi

# completion magerun
# ################################################################
# https://raw.githubusercontent.com/netz98/n98-magerun/develop/res/autocompletion/bash/n98-magerun.phar.bash
if [ -f ~/public_html/code/bash/completion/magerun.sh ]; then
    . ~/public_html/code/bash/completion/magerun.sh
elif [ -f ~/.completion/magerun.sh ]; then
    . ~/.completion/magerun.sh
fi

# bash completion for the `wp` command
# ################################################################
if [ -f ~/public_html/code/bash/completion/wp.sh ]; then
    . ~/public_html/code/bash/completion/wp.sh
elif [ -f ~/.completion/wp.sh ]; then
    . ~/.completion/wp.sh
fi

# bash completion for the `angular cli` command
# ################################################################
if [ -f ~/public_html/code/bash/completion/angular2.sh ]; then
    . ~/public_html/code/bash/completion/angular2.sh
elif [ -f ~/.completion/angular2.sh ]; then
    . ~/.completion/angular2.sh
fi
