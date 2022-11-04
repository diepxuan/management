#!/usr/bin/env bash
#!/bin/bash

--sys:env() {
    if [[ -f $_BASEDIR/.env ]]; then
        source $_BASEDIR/.env
    fi
    # DEBUG
    # echo $DEBUG
}

--sys:env:debug() {
    echo $DEBUG
}

--sys:env:dev() {
    echo $DEV
}
