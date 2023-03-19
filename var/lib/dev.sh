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
    cat debian/changelog | sed -e "s/<ductn@diepxuan.com>  .*/<ductn@diepxuan.com>  $(date -R)/g" >debian/changelog
}
