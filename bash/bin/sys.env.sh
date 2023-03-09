#!/usr/bin/env bash
#!/bin/bash

DDNS_DOMAINS="dc1.diepxuan.com dc2.diepxuan.com dc3.diepxuan.com dx1.diepxuan.com dx2.diepxuan.com dx3.diepxuan.com sql1.diepxuan.com sql2.diepxuan.com"

_DUCTN_COMMANDS+=("sys:env")
--sys:env() {
    if [[ $# == 1 ]]; then
        echo -e "${!@}"
    elif [[ $# > 1 ]]; then
        _PARAM=$1
        _VALUE=""

        for val in "$@"; do
            if [[ ! $_PARAM == $val ]]; then
                [[ $_VALUE == "" ]] && _VALUE=$val || _VALUE="$_VALUE $val"
            fi
        done

        if [[ ! -n $(grep -P "$1" $_BASEDIR/.env) ]]; then
            echo "$_PARAM=\"$_VALUE\"" >>$_BASEDIR/.env
        else
            sed -i -E "s/$_PARAM=.*/$_PARAM=\"$_VALUE\"/" $_BASEDIR/.env
        fi
    fi
}

--sys:env:list() {
    IFS=', ' read -r -a array <<<$(--sys:env "$@")
    for item in "${array[@]}"; do
        echo $item
    done
}

--sys:env:domains() {
    for domain in $(--sys:env:list "DDNS_DOMAINS"); do
        echo $domain
    done
}

--sys:env:import() {
    if [[ -f $_BASEDIR/.env ]]; then

        # while read -r _env; do
        #     if [[ ! $_env =~ ^#.* ]] && [[ $_env == *'='* ]]; then
        #         # echo $_env
        #         $_env= $(echo $_env | xargs) 2>/dev/null
        #         IFS='=' read -r -a _array <<<$_env
        #         _PARAM=$(echo "${_array[0]}" | xargs)
        #         _VALUE="$(echo "${_array[1]}" | xargs)"
        #         # eval $_PARAM=$_VALUE
        #         eval "declare $_PARAM='$_VALUE'"
        #         # echo ${!_PARAM}
        #         # eval $_PARAM="$_VALUE"
        #         # echo "$_PARAM=$_VALUE"
        #     fi
        # done <"$_BASEDIR/.env"

        source $_BASEDIR/.env
    fi
}

--sys:env:debug() {
    echo $DEBUG
}

--sys:env:dev() {
    echo $DEV
}
