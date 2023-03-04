#!/usr/bin/env bash
#!/bin/bash

# apt install isc-dhcp-server

_DUCTN_COMMANDS+=("sys:dhcp:install")
--sys:dhcp:install() {
    --sys:apt:install isc-dhcp-server
}
