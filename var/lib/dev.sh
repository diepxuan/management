#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("dev:build")
--dev:build() {
    local old_pwd=$(pwd)
    --echo "$TXTinfo goto package folder"
    --echo "$TXTinfo build package"
    --echo "==============================="
    cd /var/www/base/

    _build_time
    dpkg-buildpackage

    --echo "$TXTinfo build source"
    --echo "==============================="
    dpkg-buildpackage -S

    cd /var/www/
    mv /var/www/ductn* /var/www/ppa/ 2>/dev/null

    _build_ppa
    _dput_ppa

    --echo "$TXTinfo back to current folder"
    cd $old_pwd
}

_build_time() {
    cat debian/changelog | sed -e "0,/<ductn@diepxuan.com>  .*/ s/<ductn@diepxuan.com>  .*/<ductn@diepxuan.com>  $(date -R)/g" >debian/changelog
}

_build_ppa() {
    local old_pwd=$(pwd)
    --echo "$TXTinfo goto ppa folder"
    --echo "$TXTinfo build and push to ppa"
    --echo "==============================="
    cd /var/www/ppa/

    # Packages & Packages.gz
    dpkg-scanpackages --multiversion . >Packages
    gzip -k -f Packages

    # Release, Release.gpg & InRelease
    apt-ftparchive release . >Release
    gpg --default-key "ductn@diepxuan.com" -abs -o - Release >Release.gpg
    gpg --default-key "ductn@diepxuan.com" --clearsign -o - Release >InRelease

    # Commit & push
    git add -A
    git commit -m update
    # git push

    --echo "$TXTinfo back to current folder"
    cd $old_pwd
}

_dput_ppa() {
    --echo "$TXTinfo last version: detecting"
    local lastversion=$(ls /var/www/ppa/*source.changes | sort -V | tail -n 1)
    --echo "$TXTtrue last version: $lastversion"
    dput ductn-ppa $lastversion
}

--dev() {
    _main $@
}
