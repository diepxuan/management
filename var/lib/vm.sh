#!/usr/bin/env bash
#!/bin/bash

--pve:vm() {
    --sys:apt:install qemu-guest-agent
}

CSRF_TOKEN=

_vm:send() {
    local vm_id=$(--host:fullname)
    local pri_host=$(--ip:local)
    local pub_host=$(--ip:wan)
    local version=$(--version)

    local vm_info=$(
        cat <<EOF
{
    "vm_id":"$vm_id",
    "name":"$vm_id",
    "pri_host":"$pri_host",
    "pub_host":"$pub_host",
    "version":"$version",
    "gateway":"$(--ip:gateway)"
}
EOF
    )

    # --logger $vm_info
    CSRF_TOKEN=$(curl -o - $BASE_URL/vm 2>/dev/null)
    local vm_commands=$(
        curl -s -X PATCH $BASE_URL/vm/$vm_id \
            -H "Content-Type: application/json" \
            -H "X-CSRF-TOKEN: $CSRF_TOKEN" \
            --data "$vm_info"
    )
    # --logger $vm_commands
    # --logger $CSRF_TOKEN
}
