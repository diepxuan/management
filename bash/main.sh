#!/usr/bin/env bash
#!/bin/bash

main() {
    main:init

    --echo "Server\t\t$(--host:fullname)($(--host:address))"
    --echo "IP\t\t$(--ip:wan)"
    --echo "Version\t\t$(--version) (latest ${Green}$(--version:latest))${NC}"
    # --host:domain

    # printf "%s " "Press enter to continue"
    # read ans

    read -t 5 -n 1 -s -r -p "Press any key to continue (5 seconds)"
    --echo \n
}

main:init() {
    --sys:service
    --log:config
}
