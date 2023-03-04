#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("host:name")
--host:name() { # FQDN dc
    hostname -s
}

_DUCTN_COMMANDS+=("host:fullname")
--host:fullname() { # FQDN diepxuan.com
    hostname -f
}

_DUCTN_COMMANDS+=("host:domain")
--host:domain() { # FQDN dc.diepxuan.com
    hostname -d
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
    _IP=$@
    if expr "$_IP" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
        echo $_IP
        exit 0
    else
        echo 127.0.0.1
        exit 1
    fi
}

#_DUCTN_COMMANDS+=("host:ip")
--host:ip() {
    --host:address $@
}
