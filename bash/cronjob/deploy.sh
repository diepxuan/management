#!/bin/bash

[ -f /var/www/base/bash/deploy/.deploying ] && printf "\n$(date -Iseconds) Deploying! continue ...\n"
[ -f /var/www/base/bash/deploy/.deploying ] && exit 0

printf "\n$(date -Iseconds) Starting deploy twtools.co.uk ...\n"
touch /var/www/base/bash/deploy/.deploying

ssh local.tci "git --work-tree=/var/www/html/dev/twtools.co.uk --git-dir=/var/www/html/dev/twtools.co.uk/.git checkout -f sprint_FED_Primary"
ssh local.tci "git --work-tree=/var/www/html/dev/twtools.co.uk/app/code/Evolve --git-dir=/var/www/html/dev/twtools.co.uk/app/code/Evolve/.git checkout -f S_TWTools"
ssh local.tci "
cd /var/www/html/dev/twtools.co.uk/
composer -vvv update
magerun2 cache:enable
m2deploy
"

rm -rf /var/www/base/bash/deploy/.deploying
