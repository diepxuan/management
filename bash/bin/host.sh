#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("host:name")
--host:name() { # FQDN
    hostname -s
}

_DUCTN_COMMANDS+=("host:fullname")
--host:fullname() { # FQDN
    hostname -f
}

_DUCTN_COMMANDS+=("host:domain")
--host:domain() { # FQDN
    hostname -d
}

_DUCTN_COMMANDS+=("host:address")
--host:address() {
    if [[ ! -z ${@+x} ]]; then
        host $@ | grep -wv -e alias | cut -f4 -d' '
        exit 0
    fi
    --host:address $(--host:fullname)
}

#_DUCTN_COMMANDS+=("host:ip")
--host:ip() {
    --host:address $@
}
