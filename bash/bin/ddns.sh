#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("ddns:update")
--ddns:update() {
    --cloudflare:sync
}

# --ddns:_allow() {
#     if [ "$(whoami)" = "ductn" ]; then
#         # sudo ufw allow proto tcp from "$(--host:address $@)" to any port 1433
#         sudo ufw allow from "$(--host:address $@)"
#     fi
# }

# --ddns:update() {
#     --ddns:allow
# }

# --ddns:allow() {
#     for domain in "${DDNS_DOMAINS[@]}"; do
#     for domain in $(--sys:env:domains); do
#         --ddns:_allow $domain
#     done
# }
