#!/usr/bin/env bash
#!/bin/bash

---T() { --test; }
--exists() {
    # nothing to do
    echo '' 1>&3
}
--do_no_thing() { --exists; }

--logger() {
    logger "$*"
}

--echo() {
    echo -e "$@" 2>/dev/null
}

--version() {
    version=$(dpkg -s ductn | grep Version)
    version=${version//'Version: '/}
    echo $version
}

---v() {
    --version
}

_DUCTN_COMMANDS+=("hash_MD5")
--hash_MD5() {
    echo $RANDOM | md5sum | head -c 20
}
