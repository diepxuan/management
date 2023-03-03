#!/usr/bin/env bash
#!/bin/bash

main() {
    main:init

    _version="$([ --version:islatest ] && echo ${Green} || echo ${Red})$(--version)${NC}"

    --echo "Server\t\t$(--host:fullname)($(--host:address))"
    --echo "IP\t\t$(--ip:wan)"
    --echo "Version\t\t$_version (latest $(--version:latest))"
    # --host:domain

    # printf "%s " "Press enter to continue"
    # read ans

    # read -t 5 -n 1 -s -r -p "Press any key to continue (5 seconds)"
    # --echo \n
    exit 0
}

main:init() {
    --log:config
}
