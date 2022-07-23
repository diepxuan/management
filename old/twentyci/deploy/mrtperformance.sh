#!/bin/sh

cd /home/mrtperformance/public_html/

git fetch --all
git reset --hard origin/master

composer -vvv require partsbx/core dev-release
# composer -vvv require partsbx/core dev-master
chmod u+x bin/magento

find generated generated/code generation generation/code var/generation -maxdepth 1 -mindepth 1 -type d -not -name 'Magento' -not -name 'Composer' -not -name 'Symfony' -print0 -printf '\r\n' -exec rm -rf {} \;
magerun2 generation:flush

rm -rf var/view_preprocessed/* pub/static/frontend/* pub/static/adminhtml/* pub/static/_requirejs/*
magerun2 dev:asset:clear

magerun2 maintenance:enable
magerun2 deploy:mode:set developer
magerun2 module:enable --all
magerun2 cache:enable

bin/magento setup:upgrade
magerun2 setup:di:compile
bin/magento setup:static-content:deploy en_US en_AU --exclude-theme=PARtsBX/base

magerun2 maintenance:disable

rm -rf var/cache/* var/page_cache/* var/tmp/* var/generation/* var/di/*
magerun2 cache:clean
magerun2 cache:flush

_m2ch() {
    chmod -R g+w ${1}
    chmod g+ws ${1}
}
_m2ch app/etc
_m2ch vendor
_m2ch generated
_m2ch generation
_m2ch generation/code

_m2ch pub/static
_m2ch pub/media

_m2ch var
_m2ch var/di
_m2ch var/log
_m2ch var/cache
_m2ch var/page_cache
_m2ch var/generation
_m2ch var/view_preprocessed
_m2ch var/tmp

_m2ch wp/wp-content/themes

unset -f _m2ch

curl -I http://mrt.partsdb.com.au/?clean-varnish
# sudo varnishadm "ban req.http.host ~ mrt.partsdb.com.au"
echo "The deployment script has completed execution."
