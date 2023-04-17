#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("curl:get")
--curl:get() {
    url=$*
    {
        IFS= read -rd '' out
        IFS= read -rd '' http_code
        IFS= read -rd '' status
    } < <(
        { out=$(curl -sSL -o /dev/stderr -w "%{http_code}" $url); } 2>&1
        printf '\0%s' "$out" "$?"
    )

    # echo out $out
    # echo http_code $http_code
    # echo status $status

    [[ $status == 0 ]] && [[ $http_code == 200 ]] && echo "$out" 2>&1

}
