#!/usr/bin/env bash
#!/bin/bash

# copy from https://gist.github.com/irazasyed/a7b0a079e7727a4315b9

_DUCTN_COMMANDS+=("hosts:remove")
--hosts:remove() {
    --sys:hosts:remove $1 $2
}

_DUCTN_COMMANDS+=("hosts:add")
--hosts:add() {
    --sys:hosts:add $1 $2
}

_DUCTN_COMMANDS+=("hosts")
--hosts() {
    "--hosts:$@"
}
