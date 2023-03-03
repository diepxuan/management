#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:env")
--sys:env() {
    if [[ ! -z ${@+x} ]]; then
        for str in "${!@}"; do
            echo $str
            # echo "${!@}"
        done
    fi
}

--sys:env:domains() {
    IFS=', ' read -r -a domains <<<$(--sys:env _DDNS_DOMAINS)
    for domain in "${domains[@]}"; do
        echo $domain
    done
}

--sys:env:test() {
    for domain in $(--sys:env:domains); do
        echo $domain
    done
}

--sys:env:import() {
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
