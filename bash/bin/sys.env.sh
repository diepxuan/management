#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:env")
--sys:env() {
    if [[ ! -z ${@+x} ]]; then
        for str in "${!@}"; do
            echo -e "$str"
            # echo "${!@}"
        done
    fi
}

--sys:env:list() {
    IFS=', ' read -r -a array <<<$(--sys:env "$@")
    for item in "${array[@]}"; do
        echo $item
    done
}

--sys:env:domains() {
    for domain in $(--sys:env:list "_DDNS_DOMAINS"); do
        echo $domain
    done
}

--sys:env:import() {
    if [[ -f $_BASEDIR/.env ]]; then
        source $_BASEDIR/.env
    fi
}

--sys:env:debug() {
    echo $DEBUG
}

--sys:env:dev() {
    echo $DEV
}
