#!/usr/bin/env bash
#!/bin/bash

--pve:vm() {
    --sys:apt:install qemu-guest-agent
}

_vm:send() {
    local vm_id=$(--host:fullname)
    local pri_host=$(--ip:local)
    local pub_host=$(--ip:wan)

    local vm_info=$(
        cat <<EOF
{
    "vm_id":"$vm_id",
    "name":"$vm_id",
    "pri_host":"$pri_host",
    "pub_host":"$pub_host"
}
EOF
    )

    # echo $vm_info
    echo $BASE_URL/vm/$vm_id
    local dns_record_info=$(
        curl -X PATCH $BASE_URL/vm/$vm_id \
            -H "Content-Type: application/json" \
            --data "$vm_info"
    )
    # --log $dns_record_info
}
