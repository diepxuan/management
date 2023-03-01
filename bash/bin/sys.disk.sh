#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:disk:check")
--sys:disk:check() {
    --sys:disk:check8k
    --sys:disk:check512k
}

_DUCTN_COMMANDS+=("sys:disk:check8k")
--sys:disk:check8k() {
    dd if=/dev/zero of=/tmp/output bs=8k count=10k
    rm -f /tmp/output
}

_DUCTN_COMMANDS+=("sys:disk:check512k")
--sys:disk:check512k() {
    dd if=/dev/zero of=/tmp/output bs=512k count=1k
    rm -f /tmp/output
}
