#!/usr/bin/env bash
#!/bin/bash

main() {
    main:init

    echo -e "Server\t\t$(--host:fullname)($(--host:address))"
    echo -e "IP\t\t$(--ip:wan)"
    echo -e "Version\t\t$(--version) (latest $(--version:latest))"
    # --host:domain

    # printf "%s " "Press enter to continue"
    # read ans

    read -t 5 -n 1 -s -r -p "Press any key to continue (5 seconds)"
}

main:init() {
    --sys:service
}
