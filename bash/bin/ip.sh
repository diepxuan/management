#!/usr/bin/env bash
#!/bin/bash

_IP_EXTEND=

--ip:wan() {
    if [[ -z ${_IP_EXTEND+x} ]]; then continue; else
        _IP_EXTEND=$(dig @resolver4.opendns.com myip.opendns.com +short)
    fi
    echo $_IP_EXTEND
}

--ip:wanv4() {
    dig @resolver4.opendns.com myip.opendns.com +short -4
}

--ip:wanv6() {
    dig @resolver1.ipv6-sandbox.opendns.com AAAA myip.opendns.com +short -6
}

--ip:local() {
    hostname -I | awk '{print $1}'
}
