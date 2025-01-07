#!/usr/bin/env bash
#!/bin/bash

set -e
# set -u
. $(dirname $(realpath "$BASH_SOURCE"))/head.sh

# Update os release latest
# old_release_os=$(cat $changelog | head -n 1 | awk '{print $2}' | cut -d '+' -f2 | cut -d '~' -f1)
# sed -i -e "0,/$old_release_os/ s/$old_release_os/${DISTRIB}${RELEASE}/g" $changelog

# Update os codename
# old_codename_os=$(cat $changelog | head -n 1 | awk '{print $3}')
# sed -i -e "0,/$old_codename_os/ s/$old_codename_os/$CODENAME;/g" $changelog

# Update time building
# BUILDPACKAGE_EPOCH=${BUILDPACKAGE_EPOCH:-$(date -R)}
# sed -i -e "0,/<$email>  .*/ s/<$email>  .*/<$email>  $BUILDPACKAGE_EPOCH/g" $changelog

start_group "update package config"
cd $source_dir

release_tag=$($source_dir/ductn version:newrelease)

# old_project=$(cat $changelog | head -n 1 | awk '{print $1}' | sed 's|[()]||g')
# old_release_tag=$(cat $changelog | head -n 1 | awk '{print $2}' | sed 's|[()]||g')
# old_codename_os=$(cat $changelog | head -n 1 | awk '{print $3}' | sed 's|;||g')
package_clog=$(git log -1 --pretty=format:"%h %s" -- src/)
package_clog=${package_clog:-"Update package"}

# sed -i -e "s|$old_project|$_project|g" $changelog

# sed -i -e "s|$old_release_tag|$release_tag|g" $changelog
# sed -i -e "s|$old_codename_os|$CODENAME|g" $changelog
# sed -i -e "s|<$email>  .*|<$email>  $timelog|g" $changelog
# dch -D $CODENAME
# dch --newversion $release_tag~$DISTRIB$RELEASE --distribution $CODENAME "$package_clog"
dch --newversion $release_tag --distribution $CODENAME "$package_clog"
# dch --newversion $release_tag~$DISTRIB$RELEASE
# dch -a "$package_clog"
cd -
end_group
