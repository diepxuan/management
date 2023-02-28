#!/usr/bin/env bash
#!/bin/bash

CLFR_API="https://api.cloudflare.com/client/v4"

--cloudflare:sync() {
    if [[ "$(--cloudflare:check)" -eq 0 ]]; then
        --cloudflare:patch:recordByName $(--cloudflare:fullname)
        --host:address
    fi
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

--cloudflare:host() {
    --host:name
}

--cloudflare:fullname() {
    --host:fullname
}

--cloudflare:ip() {
    --cloudflare:get:recordIP $(--cloudflare:fullname)
}

--cloudflare:check() {
    if [[ "$(--cloudflare:ip)" == "$(--ip:wan)" ]]; then
        echo 1
    else
        echo 0
    fi
}

--cloudflare:get() {
    # echo "$(--cloudflare:token)"
    # echo "$(--cloudflare:dns:record)"
    # -H "Authorization: Bearer $(--cloudflare:token)" \
    # -H "Content-Type: application/json")
    # curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
    # dns_record_info=$(
    #     curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$(--cloudflare:domain)/dns_records?name=$(--cloudflare:dns:record)" \
    dns_record_info=$(
        curl -s -X GET $1 \
            --http1.1 \
            -H "Cache-Control: no-cache, no-store" \
            -H "Pragma: no-cache" \
            -H "X-Auth-Email: $(--cloudflare:email)" \
            -H "X-Auth-Key: $(--cloudflare:token)" \
            -H "Content-Type:application/json"
    )
    # -H "Authorization: Bearer $(--cloudflare:token)" \
    if [[ ${dns_record_info} == *"\"success\":false"* ]]; then
        # echo ${dns_record_info}
        # echo "Error! Can't get record info from cloudflare's api"
        exit 0
    else
        echo $dns_record_info
    fi
    # is_proxed=$(echo ${dns_record_info} | grep -o '"proxied":[^,]*' | grep -o '[^:]*$')
    # dns_record_ip=$(echo ${dns_record_info} | grep -o '"content":"[^"]*' | cut -d'"' -f 4)
}

--cloudflare:patch() {
    dns_record_info=$(
        curl -s -X PATCH $1 \
            --http1.1 \
            -H "Cache-Control: no-cache, no-store" \
            -H "Pragma: no-cache" \
            -H "X-Auth-Email: $(--cloudflare:email)" \
            -H "X-Auth-Key: $(--cloudflare:token)" \
            -H "Content-Type: application/json" \
            --data $2
    )
    if [[ ${dns_record_info} == *"\"success\":false"* ]]; then
        echo $dns_record_info
        exit 0
    else
        echo $dns_record_info
    fi
}

--cloudflare:get:userid() {
    echo $(--cloudflare:get $CLFR_API/user | jq -r '.result.id')
}

--cloudflare:get:zones() {
    for value in $(--cloudflare:get $CLFR_API/zones | jq -r '.result[].id'); do
        echo $value
    done
}

--cloudflare:get:records() {
    for zoneid in $(--cloudflare:get:zones); do
        echo $(--cloudflare:get $CLFR_API/zones/$zoneid/dns_records | jq -r '.result[].name')
    done
}

--cloudflare:get:recordByName() {
    for zoneid in $(--cloudflare:get:zones); do
        echo $(--cloudflare:get $CLFR_API/zones/$zoneid/dns_records\?type=A\&name=${1} | jq -r '.result[]')
    done
}

--cloudflare:get:recordid() {
    --cloudflare:get:recordByName $1 | jq -r '.id'
}

--cloudflare:get:recordIP() {
    --cloudflare:get:recordByName $1 | jq -r '.content'
}

--cloudflare:patch:recordByName() {
    for zoneid in $(--cloudflare:get:zones); do
        record=$(--cloudflare:get $CLFR_API/zones/$zoneid/dns_records\?type=A\&name=${1} | jq -r -c '.result[]')
        record=$(echo $record | jq -c -r --arg ip $(--ip:wan) '. + {"content": $ip}')
        recordid=$(echo $record | jq -r '.id')
        record=$(--cloudflare:patch $CLFR_API/zones/$zoneid/dns_records/$recordid $record)
        # echo $record
    done
}
