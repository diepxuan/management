#!/usr/bin/env bash
#!/bin/bash

main() {

    echo "Server  $(--host:domain)($(--host:address))"
    echo "IP      $(--ip:wan)"
    echo "Version $(--version) (latest $(--version:latest))"
    # --host:domain

    # printf "%s " "Press enter to continue"
    # read ans

    read -t 5 -n 1 -s -r -p "Press any key to continue"

}
