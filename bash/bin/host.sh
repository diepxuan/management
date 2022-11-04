#!/usr/bin/env bash
#!/bin/bash

_HOST=

# FQDN
--host:name() {
    hostname -s
}

# FQDN
--host:fullname() {
    hostname -f
}

# FQDN
--host:domain() {
    hostname -d
}

--host:address() {
    if [[ ! -z ${@+x} ]]; then
        host $@ | grep -wv -e alias | cut -f4 -d' '
        exit 0
    fi
    --host:address $(--host:fullname)
}

--host:ip() {
    --host:address $@
}
