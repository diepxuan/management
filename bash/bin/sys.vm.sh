#!/usr/bin/env bash
#!/bin/bash

--sys:vm:enable() {
    sudo apt install qemu-guest-agent -y --purge --auto-remove
    sudo systemctl enable qemu-guest-agent
    sudo systemctl restart qemu-guest-agent
}
