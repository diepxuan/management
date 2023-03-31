#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("dev:build")
--dev:build() {
    _build_time
    dpkg-buildpackage
    dpkg-buildpackage -S
    local old_pwd=$(pwd)
    cd /var/www/
    mv ductn* ppa/ 2>/dev/null
    cd /var/www/ppa/
    _build_ppa
}

_build_time() {
    cat debian/changelog | sed -e "0,/<ductn@diepxuan.com>  .*/ s/<ductn@diepxuan.com>  .*/<ductn@diepxuan.com>  $(date -R)/g" >debian/changelog
}

_build_ppa() {
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
}

--dev() {
    _main $@
}
