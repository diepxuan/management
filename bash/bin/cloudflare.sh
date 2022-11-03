#!/usr/bin/env bash
#!/bin/bash

--cloudflare:sync() {
    --cloudflare:token
}

--cloudflare:email() {
    cat $_BASHDIR/certbot/cloudflare.ini | grep -o 'dns_cloudflare_email[[:space:]]*=[[:space:]]*[^,]*' | grep -o '[^= ]*$'
}

--cloudflare:token() {
    cat $_BASHDIR/certbot/cloudflare.ini | grep -o 'dns_cloudflare_api_key[[:space:]]*=[[:space:]]*[^,]*' | grep -o '[^= ]*$'
}

--cloudflare:domain() {
    --host:domain
}

--cloudflare:dns:record() {
    --host:name
}

--cloudflare:check() {
    if [[ "${--host:ip}" -eq "${--ip:wan}" ]]; then
        echo "match"
    fi
}

--cloudflare:get() {
    echo "$(--cloudflare:token)"
    # echo "$(--cloudflare:dns:record)"
    # dns_record_info=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$(--cloudflare:domain)/dns_records?name=$(--cloudflare:dns:record)" \
    # -H "Authorization: Bearer $(--cloudflare:token)" \
    # -H "Content-Type: application/json")
    dns_record_info=$(curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
        -H "X-Auth-Email: $(--cloudflare:email)" \
        -H "X-Auth-Key: $(--cloudflare:token)" \
        -H "Content-Type:application/json")
    # -H "Authorization: Bearer $(--cloudflare:token)" \
    # if [[ ${dns_record_info} == *"\"success\":false"* ]]; then
    #     echo ${dns_record_info}
    #     echo "Error! Can't get dns record info from cloudflare's api"
    #     exit 0
    # fi
    # is_proxed=$(echo ${dns_record_info} | grep -o '"proxied":[^,]*' | grep -o '[^:]*$')
    # dns_record_ip=$(echo ${dns_record_info} | grep -o '"content":"[^"]*' | cut -d'"' -f 4)
    echo $dns_record_info
}
