#!/usr/bin/env bash
#!/bin/bash

--sys:base:upgrade() {
    if [[ $(--sys:env:dev) -eq 1 ]]; then
        --sys:base:dev
    else
        --sys:base:bin
    fi
    ductn sys:init
    ductn sys:service:re-install
    exit 0
}

--sys:base:dev() {
    mkdir -p "$_BASEDIR"
    cd "$_BASEDIR"
    git fetch -ap
    git reset --hard origin/master
    --git:configure

    echo "DEV=1" >>$_BASEDIR/.env
}

--sys:base:bin() {
    mkdir -p "$_BASEDIR"
    cd "$_BASEDIR"
    git archive --remote=git@bitbucket.org:DXVN/code.git master | tar -x -C "${_BASEDIR}"
}

_DUCTN_COMMANDS+=("sys:selfupdate" "selfupdate" "self-update")
--selfupdate() { --sys:selfupdate; }
--self-update() { --sys:selfupdate; }
--sys:selfupdate() {
    if [[ $(--version:islatest) -eq 0 ]]; then
        --sys:base:upgrade
    fi
}
