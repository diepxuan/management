#!/usr/bin/env bash
#!/bin/bash

--test() {
    echo -e "ductn proccess version: $(--version)"
}
---T() { --test; }
--exists() {
    # nothing to do
    echo '' 1>&3
}
--do_no_thing() { --exists; }

--logger() {
    logger "$@"
}

--echo() {
    echo -e "$@" 2>/dev/null
}
