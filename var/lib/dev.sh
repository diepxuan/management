#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("dev:build")
--dev:build() {
    _update_time
    dpkg-buildpackage
}

_DUCTN_COMMANDS+=("dev:source")
--dev:source() {
    _update_time
    dpkg-buildpackage -S
}

_update_time() {
    cat debian/changelog | sed -e "0,/<ductn@diepxuan.com>  .*/ s/<ductn@diepxuan.com>  .*/<ductn@diepxuan.com>  $(date -R)/g" >debian/changelog
}

--dev:ppa() {
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
