#!/usr/bin/env bash
#!/bin/bash

DDNS_DOMAINS=()
# DDNS_DOMAINS+=("dxvnkthd.diepxuan.com" "dxvnk113.diepxuan.com" "dxvnkkcn.diepxuan.com" "dxvnmg15.diepxuan.com")
DDNS_DOMAINS+=("dc1.diepxuan.com" "dc2.diepxuan.com" "dc3.diepxuan.com")
DDNS_DOMAINS+=("dx1.diepxuan.com" "dx2.diepxuan.com" "dx3.diepxuan.com")
DDNS_DOMAINS+=("sql1.diepxuan.com" "sql2.diepxuan.com")

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
#         --ddns:_allow $domain
#     done
# }
