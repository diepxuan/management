#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("dev:build")
--dev:build() {
    # changelog=$(cat debian/changelog)
    cat debian/changelog | sed -e "s/<ductn@diepxuan.com>  .*/<ductn@diepxuan.com>  $(date -R)/g" >debian/changelog

    dpkg-buildpackage
}

_DUCTN_COMMANDS+=("dev:source")
--dev:source() {
    dpkg-buildpackage -S
}
