#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:vm:enable")
--sys:vm:enable() {
    sudo apt install qemu-guest-agent -y --purge --auto-remove
    sudo systemctl enable qemu-guest-agent
    sudo systemctl restart qemu-guest-agent
}

_DUCTN_COMMANDS+=("sys:vm:new")
--sys:vm:new() {
    --ssh:copy $1@$2
    ssh $1@$2 "sudo mkdir -p $_BASEDIR"
    ssh $1@$2 "sudo chown -R ductn:ductn $_BASEDIR"
    ssh $1@$2 "git archive --remote=git@bitbucket.org:DXVN/code.git master | tar -x -C $_BASEDIR"
    ssh $1@$2 "$_BASHDIR/ductn user:new ductn"
    ssh $1@$2 "$_BASHDIR/ductn sys:init"
}
