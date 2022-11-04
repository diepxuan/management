#!/usr/bin/env bash
#!/bin/bash

--sys:base:upgrade() {
    if [[ $(--sys:env:dev) -eq 1 ]]; then
        --sys:base:dev
    else
        --sys:base:bin
    fi
}

--sys:base:dev() {
    mkdir -p "$_BASEDIR"
    cd "$_BASEDIR"
    git fetch -ap
    git reset --hard origin/master
    echo "DEV=1" >>$_BASEDIR/.env
}

--sys:base:bin() {
    mkdir -p "$_BASEDIR"
    cd "$_BASEDIR"
    git archive --remote=git@bitbucket.org:DXVN/code.git master | tar -x -C "${_BASEDIR}"
}

--sys:selfupdate() {
    if [[ $(--version:islatest) -eq 1 ]]; then
        --sys:base:upgrade
    fi
}

--selfupdate() {
    --sys:selfupdate
    --sys:init
}

--self-update() {
    --selfupdate
}
