#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("host:name")
--host:name() { # FQDN dc
    hostname -s
}

_DUCTN_COMMANDS+=("host:domain")
--host:domain() { # FQDN dc.diepxuan.com
    hostname -d
}

_DUCTN_COMMANDS+=("host:fullname")
--host:fullname() { # FQDN diepxuan.com
    hostname -f
}

_DUCTN_COMMANDS+=("host:address")
--host:address() {
    if [[ ! -z ${@+x} ]]; then
        --host:address:valid $(host $@ | grep -wv -e alias | cut -f4 -d' ')
        exit 0
    fi
    --host:address $(--host:fullname)
}

--host:address:valid() {
    --ip:valid $@
}

#_DUCTN_COMMANDS+=("host:ip")
--host:ip() {
    --host:address $@
}

--host:is_server() {
    [[ $(--host:fullname) =~ ^pve[0-9].diepxuan.com$ ]] && echo 1 || echo 0
}

--host:is_vpn_server() {
    [[ $(--host:fullname) =~ ^pve[0-9].vpn$ ]] && echo 1 || echo 0
}
