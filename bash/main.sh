#!/usr/bin/env bash
#!/bin/bash

if [[ ! -z ${@+x} ]]; then
    "--$@"
    exit 0
else
    --host:domain
    # --host:domain

    # printf "%s " "Press enter to continue"
    # read ans

    read -t 5 -n 1 -s -r -p "Press any key to continue"
    exit 0
fi
