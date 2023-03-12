#!/usr/bin/env bash
#!/bin/bash

_BASEDIR="/var/www/base"
_BASHDIR="$_BASEDIR/bash"
_LIBDIR="$_BASEDIR/lib"
_BINDIR="$_BASHDIR/bin"

_DUCTN_COMMANDS=()

_MYSQL_REPLICATE=""
_MYSQL_REPLICATE_TOOGLE=""
_MYSQL_REPLICATE_TOOGLE=""
_MYSQL_REPLICATE_HOST=0

DEBUG=0
DEV=0

USER_BIN_PATH=/home/ductn/bin
LOCAL_BIN_PATH=/usr/local/bin
DIRTMP=/tmp/ductn

SERVICE_DESC="Ductn service"
SERVICE_NAME=ductnd
# SERVICE_PATH="/var/www/base/bash/ductn.sh run_as_service"
SERVICE_PATH="$LOCAL_BIN_PATH/ductn run_as_service"

# Ket noi den vpn server
# _IPTUNEL="pve2:1.1.1.1"

# Danh sach domain luon luon allow
# DDNS_DOMAINS="domain1.diepxuan.com domain2.diepxuan.com"

NAT="3389:10.0.pve.10"
NAT="1433:10.0.pve.11"

#!/usr/bin/env bash
#!/bin/bash

# printf "I ${RED}love${NC} Stack Overflow\n"
# echo -e "I ${RED}love${NC} Stack Overflow"

# Reset
Color_Off='\033[0m' # Text Reset
NC='\033[0m'        # No Color

# Regular Colors
Black='\033[0;30m'  # Black
Red='\033[0;31m'    # Red
Green='\033[0;32m'  # Green
Yellow='\033[0;33m' # Yellow
Blue='\033[0;34m'   # Blue
Purple='\033[0;35m' # Purple
Cyan='\033[0;36m'   # Cyan
White='\033[0;37m'  # White

# Bold
BBlack='\033[1;30m'  # Black
BRed='\033[1;31m'    # Red
BGreen='\033[1;32m'  # Green
BYellow='\033[1;33m' # Yellow
BBlue='\033[1;34m'   # Blue
BPurple='\033[1;35m' # Purple
BCyan='\033[1;36m'   # Cyan
BWhite='\033[1;37m'  # White

# Underline
UBlack='\033[4;30m'  # Black
URed='\033[4;31m'    # Red
UGreen='\033[4;32m'  # Green
UYellow='\033[4;33m' # Yellow
UBlue='\033[4;34m'   # Blue
UPurple='\033[4;35m' # Purple
UCyan='\033[4;36m'   # Cyan
UWhite='\033[4;37m'  # White

# Background
On_Black='\033[40m'  # Black
On_Red='\033[41m'    # Red
On_Green='\033[42m'  # Green
On_Yellow='\033[43m' # Yellow
On_Blue='\033[44m'   # Blue
On_Purple='\033[45m' # Purple
On_Cyan='\033[46m'   # Cyan
On_White='\033[47m'  # White

# High Intensity
IBlack='\033[0;90m'  # Black
IRed='\033[0;91m'    # Red
IGreen='\033[0;92m'  # Green
IYellow='\033[0;93m' # Yellow
IBlue='\033[0;94m'   # Blue
IPurple='\033[0;95m' # Purple
ICyan='\033[0;96m'   # Cyan
IWhite='\033[0;97m'  # White

# Bold High Intensity
BIBlack='\033[1;90m'  # Black
BIRed='\033[1;91m'    # Red
BIGreen='\033[1;92m'  # Green
BIYellow='\033[1;93m' # Yellow
BIBlue='\033[1;94m'   # Blue
BIPurple='\033[1;95m' # Purple
BICyan='\033[1;96m'   # Cyan
BIWhite='\033[1;97m'  # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'  # Black
On_IRed='\033[0;101m'    # Red
On_IGreen='\033[0;102m'  # Green
On_IYellow='\033[0;103m' # Yellow
On_IBlue='\033[0;104m'   # Blue
On_IPurple='\033[0;105m' # Purple
On_ICyan='\033[0;106m'   # Cyan
On_IWhite='\033[0;107m'  # White

# |       | bash  | hex     | octal   | NOTE                         |
# |-------+-------+---------+---------+------------------------------|
# | start | \e    | \x1b    | \033    |                              |
# | start | \E    | \x1B    | -       | x cannot be capital          |
# | end   | \e[0m | \x1b[0m | \033[0m |                              |
# | end   | \e[m  | \x1b[m  | \033[m  | 0 is appended if you omit it |
# |       |       |         |         |                              |
# regular usage: \033[32mThis is in green\033[0m
# for PS0/1/2/4: \[\033[32m\]This is in green\[\033[m\]

# | color       | bash         | hex            | octal          | NOTE                                  |
# |-------------+--------------+----------------+----------------+---------------------------------------|
# | start green | \e[32m<text> | \x1b[32m<text> | \033[32m<text> | m is NOT optional                     |
# | reset       | <text>\e[0m  | <text>\1xb[0m  | <text>\033[om  | o is optional (do it as best practice |
# |             |              |                |                |                                       |

################# 24 bit #########################
# |------------+-----------+-----------+---------+-------------+------------------------------------------+-----------------|
# | foreground | octal     | hex       | bash    | description | example                                  | NOTE            |
# |------------+-----------+-----------+---------+-------------+------------------------------------------+-----------------|
# |      0-255 | \033[38;2 | \x1b[38;2 | \e[38;2 | R = red     | echo -e '\033[38;2;255;0;02m####\033[m'  | R=255, G=0, B=0 |
# |      0-255 | \033[38;2 | \x1b[38;2 | \e[38;2 | G = green   | echo -e '\033[38;2;;0;255;02m####\033[m' | R=0, G=255, B=0 |
# |      0-255 | \033[38;2 | \x1b[38;2 | \e[38;2 | B = blue    | echo -e '\033[38;2;0;0;2552m####\033[m'  | R=0, G=0, B=255 |
# |------------+-----------+-----------+---------+-------------+------------------------------------------+-----------------|
# | background | octal     | hex       | bash    | description | example                                  | NOTE            |
# |------------+-----------+-----------+---------+-------------+------------------------------------------+-----------------|
# |      0-255 | \033[48;2 | \x1b[48;2 | \e[48;2 | R = red     | echo -e '\033[48;2;255;0;02m####\033[m'  | R=255, G=0, B=0 |
# |      0-255 | \033[48;2 | \x1b[48;2 | \e[48;2 | G = green   | echo -e '\033[48;2;;0;255;02m####\033[m' | R=0, G=255, B=0 |
# |      0-255 | \033[48;2 | \x1b[48;2 | \e[48;2 | B = blue    | echo -e '\033[48;2;0;0;2552m####\033[m'  | R=0, G=0, B=255 |
# |------------+-----------+-----------+---------+-------------+------------------------------------------+-----------------|

################# 8 bit #########################
# |------------+-----------+-----------+---------+------------------+------------------------------------+-------------------------|
# | foreground | octal     | hex       | bash    | description      | example                            | NOTE                    |
# |------------+-----------+-----------+---------+------------------+------------------------------------+-------------------------|
# |        0-7 | \033[38;5 | \x1b[38;5 | \e[38;5 | standard. normal | echo -e '\033[38;5;1m####\033[m'   |                         |
# |       8-15 |           |           |         | standard. light  | echo -e '\033[38;5;9m####\033[m'   |                         |
# |     16-231 |           |           |         | more resolution  | echo -e '\033[38;5;45m####\033[m'  | has no specific pattern |
# |    232-255 |           |           |         |                  | echo -e '\033[38;5;242m####\033[m' | from black to white     |
# |------------+-----------+-----------+---------+------------------+------------------------------------+-------------------------|
# | foreground | octal     | hex       | bash    | description      | example                            | NOTE                    |
# |------------+-----------+-----------+---------+------------------+------------------------------------+-------------------------|
# |        0-7 |           |           |         | standard. normal | echo -e '\033[48;5;1m####\033[m'   |                         |
# |       8-15 |           |           |         | standard. light  | echo -e '\033[48;5;9m####\033[m'   |                         |
# |     16-231 |           |           |         | more resolution  | echo -e '\033[48;5;45m####\033[m'  |                         |
# |    232-255 |           |           |         |                  | echo -e '\033[48;5;242m####\033[m' | from black to white     |
# |------------+-----------+-----------+---------+------------------+------------------------------------+-------------------------|
# for code in {0..255}; do echo -e "\e[38;05;${code}m $code: Test"; done

################# 3/4 bit #########################
# |------------+----------+---------+-------+------------------+------------------------------+--------------------------------------|
# | color-mode | octal    | hex     | bash  | description      | example (= in octal)         | NOTE                                 |
# |------------+----------+---------+-------+------------------+------------------------------+--------------------------------------|
# |          0 | \033[0m  | \x1b[0m | \e[0m | reset any affect | echo -e "\033[0m"            | 0m equals to m                       |
# |          1 | \033[1m  |         |       | light (= bright) | echo -e "\033[1m####\033[m"  | -                                    |
# |          2 | \033[2m  |         |       | dark (= fade)    | echo -e "\033[2m####\033[m"  | -                                    |
# |------------+----------+---------+-------+------------------+------------------------------+--------------------------------------|
# |  text-mode | ~        |         |       | ~                | ~                            | ~                                    |
# |------------+----------+---------+-------+------------------+------------------------------+--------------------------------------|
# |          3 | \033[3m  |         |       | italic           | echo -e "\033[3m####\033[m"  |                                      |
# |          4 | \033[4m  |         |       | underline        | echo -e "\033[4m####\033[m"  |                                      |
# |          5 | \033[5m  |         |       | blink (slow)     | echo -e "\033[3m####\033[m"  |                                      |
# |          6 | \033[6m  |         |       | blink (fast)     | ?                            | not wildly support                   |
# |          7 | \003[7m  |         |       | reverse          | echo -e "\033[7m####\033[m"  | it affects the background/foreground |
# |          8 | \033[8m  |         |       | hide             | echo -e "\033[8m####\033[m"  | it affects the background/foreground |
# |          9 | \033[9m  |         |       | cross            | echo -e "\033[9m####\033[m"  |                                      |
# |------------+----------+---------+-------+------------------+------------------------------+--------------------------------------|
# | foreground | ~        |         |       | ~                | ~                            | ~                                    |
# |------------+----------+---------+-------+------------------+------------------------------+--------------------------------------|
# |         30 | \033[30m |         |       | black            | echo -e "\033[30m####\033[m" |                                      |
# |         31 | \033[31m |         |       | red              | echo -e "\033[31m####\033[m" |                                      |
# |         32 | \033[32m |         |       | green            | echo -e "\033[32m####\033[m" |                                      |
# |         33 | \033[33m |         |       | yellow           | echo -e "\033[33m####\033[m" |                                      |
# |         34 | \033[34m |         |       | blue             | echo -e "\033[34m####\033[m" |                                      |
# |         35 | \033[35m |         |       | purple           | echo -e "\033[35m####\033[m" | real name: magenta = reddish-purple  |
# |         36 | \033[36m |         |       | cyan             | echo -e "\033[36m####\033[m" |                                      |
# |         37 | \033[37m |         |       | white            | echo -e "\033[37m####\033[m" |                                      |
# |------------+----------+---------+-------+------------------+------------------------------+--------------------------------------|
# |         38 | 8/24     |                    This is for special use of 8-bit or 24-bit                                            |
# |------------+----------+---------+-------+------------------+------------------------------+--------------------------------------|
# | background | ~        |         |       | ~                | ~                            | ~                                    |
# |------------+----------+---------+-------+------------------+------------------------------+--------------------------------------|
# |         40 | \033[40m |         |       | black            | echo -e "\033[40m####\033[m" |                                      |
# |         41 | \033[41m |         |       | red              | echo -e "\033[41m####\033[m" |                                      |
# |         42 | \033[42m |         |       | green            | echo -e "\033[42m####\033[m" |                                      |
# |         43 | \033[43m |         |       | yellow           | echo -e "\033[43m####\033[m" |                                      |
# |         44 | \033[44m |         |       | blue             | echo -e "\033[44m####\033[m" |                                      |
# |         45 | \033[45m |         |       | purple           | echo -e "\033[45m####\033[m" | real name: magenta = reddish-purple  |
# |         46 | \033[46m |         |       | cyan             | echo -e "\033[46m####\033[m" |                                      |
# |         47 | \033[47m |         |       | white            | echo -e "\033[47m####\033[m" |                                      |
# |------------+----------+---------+-------+------------------+------------------------------+--------------------------------------|
# |         48 | 8/24     |                    This is for special use of 8-bit or 24-bit                                            |                                                                                       |
# |------------+----------+---------+-------+------------------+------------------------------+--------------------------------------|


--init() {
    mkdir -p /tmp/ductn
    sudo chmod 777 -R /tmp/ductn

    --sys:env:import
    --install
}

#!/usr/bin/env bash
#!/bin/bash

CLFR_API="https://api.cloudflare.com/client/v4"

_DUCTN_COMMANDS+=("cloudflare:sync")
--cloudflare:sync() {
    if [[ "$(--cloudflare:check)" -eq 0 ]]; then
        --cloudflare:patch:recordByName $(--cloudflare:fullname)
        --cloudflare:ip
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

_DUCTN_COMMANDS+=("cloudflare:fullname")
--cloudflare:fullname() {
    --host:fullname
}

_DUCTN_COMMANDS+=("cloudflare:ip")
--cloudflare:ip() {
    --cloudflare:get:recordIP $(--cloudflare:fullname)
}

_DUCTN_COMMANDS+=("cloudflare:check")
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

_DUCTN_COMMANDS+=("cloudflare:get:userid")
--cloudflare:get:userid() {
    echo $(--cloudflare:get $CLFR_API/user | jq -r '.result.id')
}

_DUCTN_COMMANDS+=("cloudflare:get:zones")
--cloudflare:get:zones() {
    for value in $(--cloudflare:get $CLFR_API/zones | jq -r '.result[].id'); do
        echo $value
    done
}

_DUCTN_COMMANDS+=("cloudflare:get:records")
--cloudflare:get:records() {
    for zoneid in $(--cloudflare:get:zones); do
        echo $(--cloudflare:get $CLFR_API/zones/$zoneid/dns_records | jq -r '.result[].name')
    done
}

_DUCTN_COMMANDS+=("cloudflare:get:recordByName")
--cloudflare:get:recordByName() {
    for zoneid in $(--cloudflare:get:zones); do
        echo $(--cloudflare:get $CLFR_API/zones/$zoneid/dns_records\?type=A\&name=${1} | jq -r '.result[]')
    done
}

_DUCTN_COMMANDS+=("cloudflare:get:recordid")
--cloudflare:get:recordid() {
    --cloudflare:get:recordByName $1 | jq -r '.id'
}

_DUCTN_COMMANDS+=("cloudflare:get:recordIP")
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
#!/usr/bin/env bash
#!/bin/bash

--cron:cronjob:min() {
    --sys:service:cron
}

--cron:cronjob:5min() {
    --cron:install
    --sys:ufw
    # --dns:update
    --ddns:update
    [[ $(ductn sys:env:debug) -eq 0 ]] && --sys:selfupdate
}

--cron:cronjob:hour() {
    # --ufw:geoip:configuration
    --cron:service
}

--cron:cronjob:month() {
    --ufw:geoip:configuration
}

# _DUCTN_COMMANDS+=("cron:service")
# --cron:service() {
#     --sys:service:cron
# }

--cron:cronjob() {
    --cron:cronjob:5min
}

_DUCTN_COMMANDS+=("cron:update")
--cron:update() {
    --cron:cronjob:5min
}

_DUCTN_COMMANDS+=("cron:install")
--cron:install() { --cron:crontab:install; }
--cron:crontab:install() {
    if [ ! "$(--sys:service:isactive)" == "active" ]; then
        if [ "$(whoami)" = "ductn" ]; then
            # chmod u+x $_BASHDIR/cronjob/*.sh
            # chmod u+x $_BASHDIR/cronjob/cronjob
            crontab $_BASHDIR/cronjob/cronjob.conf
        fi
    fi
}

_DUCTN_COMMANDS+=("cron:uninstall")
--cron:uninstall() { --cron:crontab:uninstall; }
--cron:crontab:uninstall() {
    crontab -r
    sudo service cron restart
}
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
#!/bin/bash

NS1=false
NS2=false
# DEV=0

--dns:init() {
    if [[ -z ${NS1+x} ]]; then return; else
        NS1="$(--host:address dc1.diepxuan.com)"
        if [[ ! $NS1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            NS1=192.168.11.9
            exit 1
        fi
    fi
    if [[ -z ${NS1+x} ]]; then return; else
        NS2="$(--host:address dc2.diepxuan.com)"
        if [[ ! $NS2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            NS2=192.168.11.9
            exit 1
        fi
    fi
}

--dns:update() {
    --force() {
        DEV=1
    }
    $@
    --dns:init
    --dns:_update
}

--dns:_update() {
    if [[ -f /var/cache/bind/ns1.diepxuan.com ]] && [[ -f /var/cache/bind/ns2.diepxuan.com ]]; then
        if [[ "$NS1" =~ $(</var/cache/bind/ns1.diepxuan.com) ]] && [[ "$NS2" =~ $(</var/cache/bind/ns2.diepxuan.com) ]]; then
            if [[ $DEV -eq 0 ]]; then
                return 0
            fi
        else
            echo "$NS1" | sudo tee /var/cache/bind/ns1.diepxuan.com >/dev/null
            echo "$NS2" | sudo tee /var/cache/bind/ns2.diepxuan.com >/dev/null
        fi
    fi

    --dns:update:nameservers
    --dns:update:options
    --dns:update:named

    sudo systemd-resolve --flush-caches
    # sudo rndc flush
    # sudo rndc reload
    sudo rndc reconfig
    sudo service named restart
}

--dns:uninstall() {
    sudo netplan set ethernets.ens192=
    sudo netplan apply
    sudo apt remove bind9 bind9utils bind9-doc -y
}

--dns:update:nameservers() {
    if [[ -f /etc/resolvconf/resolv.conf.d/base ]]; then
        echo "nameserver "$NS1"" | sudo tee /etc/resolvconf/resolv.conf.d/base >/dev/null
    fi
    # sudo netplan set ethernets.ens192.nameservers.addresses=[127.0.0.1,1.1.1.1,8.8.8.8]
    # sudo netplan set ethernets.ens192.nameservers.search=["diepxuan.com","diepxuan.site"]
    sudo netplan apply
}

--dns:update:named() {
    echo "zone \"diepxuan.site\" {
    type slave;
    file \"/var/cache/bind/db.diepxuan.site\";
    notify yes;
    allow-update {
        "$NS1";
        "$NS2";
    };
    allow-transfer {
        "$NS1";
        "$NS2";
    };
};
zone \"diepxuan.com\" {
    type slave;
    file \"/var/cache/bind/db.diepxuan.com\";
    notify yes;
    allow-update {
        "$NS1";
        "$NS2";
    };
    allow-transfer {
        "$NS1";
        "$NS2";
    };
};" | sudo tee /etc/bind/named.conf.local >/dev/null
    echo "" | sudo tee /etc/bind/named.conf.local >/dev/null
}

--dns:update:tsl() {
    if [[ -f /etc/letsencrypt/live/diepxuan.com/privkey.pem ]]; then
        sudo mkdir -p /etc/bind/ssl/diepxuan.com
        sudo cp /etc/letsencrypt/live/diepxuan.com/privkey.pem /etc/bind/ssl/diepxuan.com/privkey.pem
        sudo cp /etc/letsencrypt/live/diepxuan.com/fullchain.pem /etc/bind/ssl/diepxuan.com/fullchain.pem
        sudo chmod 755 /etc/bind/ssl/diepxuan.com
        sudo chmod -R 644 /etc/bind/ssl/diepxuan.com/*
    fi
}

--dns:update:options() {
    --dns:update:tsl
    echo "# tls local-tls {
#    key-file \"/etc/bind/ssl/diepxuan.com/privkey.pem\";
#    cert-file \"/etc/bind/ssl/diepxuan.com/fullchain.pem\";
# };
options {
    directory \"/var/cache/bind\";
    forwarders {
        # 94.140.14.14;
        # 94.140.15.15;
        "$NS1";
        "$NS2";
        1.1.1.1;
        8.8.8.8;
    };
    forward only;
    dnssec-validation auto;

    allow-recursion { any; };
    recursion yes;

    auth-nxdomain no;
    allow-transfer {
        "$NS1";
        "$NS2";
    };

    listen-on-v6 {any;};
    # listen-on port 8443 tls local-tls http default {any;};
    # listen-on-v6 port 8443 tls local-tls http default {any;};

    masterfile-format text;
    also-notify {
        "$NS1";
        "$NS2";
    };
};" | sudo tee /etc/bind/named.conf.options >/dev/null
}

--dns:server:install() {
    #!/bin/bash
    cd "$(dirname "$0")"

    # sudo apt install bind9 bind9utils bind9-doc dnsutils -y

    # cat dns/slave.conf.options | ssh dx1.diepxuan.com "sudo tee /etc/bind/named.conf.options"
    # cat dns/slave.conf.local | ssh dx1.diepxuan.com "sudo tee /etc/bind/named.conf.local"
    # scp dns/db.* ductn@dx1.diepxuan.com
    # ssh dx1.diepxuan.com "
    #         mkdir /etc/bind/zones
    #         sudo mv db.* /etc/bind/zones
    #         sudo service bind9 restart
    #     "

    # cat dns/master.conf.options | ssh dx3.diepxuan.com "sudo tee /etc/bind/named.conf.options"
    # cat dns/master.conf.local | ssh dx3.diepxuan.com "sudo tee /etc/bind/named.conf.local"
    # scp dns/db.* ductn@dx3.diepxuan.com:~/
    # ssh dx3.diepxuan.com "
    #         mkdir -p /etc/bind/zones
    #         sudo mv ~/db.* /etc/bind/zones
    #         sudo service bind9 restart
    #     "

    # sudo apt install stunnel4 -y --purge --auto-remove
    # cat /var/www/base/bash/dns/stunnel.conf | sudo tee /etc/stunnel/stunnel.conf
    # sudo service bind9 restart

    # sudo nano /etc/apparmor.d/local/usr.sbin.named
    # add line:
    # /etc/letsencrypt/** r,
    #
    # sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.named
    # sudo service apparmor restart
    #
    # sudo chmod 750 /etc/letsencrypt/live/
    # sudo chmod 750 /etc/letsencrypt/archive/
    # sudo chgrp bind /etc/letsencrypt/live/diepxuan.com/privkey.pem
    # sudo chmod 0640 /etc/letsencrypt/live/diepxuan.com/privkey.pem
}
#!/usr/bin/env bash
#!/bin/bash

_GITDIR="$_LIBDIR/git"

_DUCTN_COMMANDS+=("git:configure")
--git:configure() {
    if [[ -d $_BASEDIR/.git ]]; then
        # global gitignore
        git config --global core.excludesfile ~/.gitignore

        # setting
        git config --global user.name "Tran Ngoc Duc"
        git config --global user.email "caothu91@gmail.com"

        # alias
        git config --global alias.plog "log --graph --pretty=format:'%h -%d %s %n' --abbrev-commit --date=relative --branches"

        # push
        git config --global push.default simple

        # file mode
        git config --global core.fileMode false

        # line endings
        git config --global core.autocrlf false
        git config --global core.eol lf

        # Cleanup
        git config --global gc.auto 0

        # remote server
        git config --global receive.denyCurrentBranch updateInstead

        if [ "$(whoami)" = "ductn" ]; then
            cd $_BASEDIR

            cat $_GITDIR/.gitignore >~/.gitignore
            chmod 644 ~/.gitignore

            # remote repository
            cat $_GITDIR/push-to-checkout >$_BASEDIR/.git/hooks/push-to-checkout
            cat $_GITDIR/pre-commit >$_BASEDIR/.git/hooks/pre-commit
            rm -rf $_BASEDIR/.git/hooks/post-receive
            chmod +x $_BASEDIR/.git/hooks/*
        fi
    fi
}

_DUCTN_COMMANDS+=("git:configure:server")
--git:configure:server() {
    if [[ -d $_BASEDIR/.git ]]; then
        echo "server update"
        cat $_GITDIR/post-receive >$_BASEDIR/.git/hooks/post-receive
        chmod +x .git/hooks/*
    fi
}
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("host:name")
--host:name() { # FQDN dc
    hostname -s
}

_DUCTN_COMMANDS+=("host:domain")
--host:domain() { # FQDN dc.diepxuan.com
    hostname -d
}

_DUCTN_COMMANDS+=("host:fullname")
--host:fullname() { # FQDN diepxuan.com
    hostname -f
}

_DUCTN_COMMANDS+=("host:address")
--host:address() {
    if [[ ! -z ${@+x} ]]; then
        --host:address:valid $(host $@ | grep -wv -e alias | cut -f4 -d' ')
        exit 0
    fi
    --host:address $(--host:fullname)
}

--host:address:valid() {
    --ip:valid $@
}

#_DUCTN_COMMANDS+=("host:ip")
--host:ip() {
    --host:address $@
}

--host:is_server() {
    [[ $(--host:fullname) =~ ^pve[0-9].diepxuan.com$ ]] && echo 1 || echo 0
}

--host:is_vpn_server() {
    [[ $(--host:fullname) =~ ^pve[0-9].vpn$ ]] && echo 1 || echo 0
}
#!/usr/bin/env bash
#!/bin/bash

# copy from https://gist.github.com/irazasyed/a7b0a079e7727a4315b9

_DUCTN_COMMANDS+=("hosts:remove")
--hosts:remove() {
    --sys:hosts:remove $1 $2
}

_DUCTN_COMMANDS+=("hosts:add")
--hosts:add() {
    --sys:hosts:add $1 $2
}

_DUCTN_COMMANDS+=("hosts")
--hosts() {
    "--hosts:$@"
}
#!/usr/bin/env bash
#!/bin/bash

_HTTPDDIR="$_LIBDIR/httpd"

_DUCTN_COMMANDS+=("httpd:install")
--httpd:install() {
    #!/usr/bin/env bash

    # CREATE Dav Access
    ###################
    # mkdir -p /var/www/DavLock
    sudo a2enmod dav dav_fs auth_digest &>/dev/null
    sudo chmod 775 /var/www/
    sudo chown :www-data /var/www/

    # APPLY APACHE CONFIG
    #####################
    sudo a2ensite ductn.conf
    # sudo a2dismod mpm_prefork mpm_worker mpm_event

    # sudo apt-get install libapache2-mpm-itk
    # sudo a2enmod mpm_itk

    sudo a2enmod proxy proxy_http headers deflate expires rewrite mcrypt reqtimeout vhost_alias ssl env dir mime &>/dev/null

    # sudo a2dismod php?.?
    # sudo a2enmod php7.1

    sudo apache2ctl configtest
    sudo service apache2 restart
    # sudo service apache2 status

}

_DUCTN_COMMANDS+=("httpd:config")
--httpd:config() {
    --chmod() {
        --httpd:config:chmod
    }

    --httpd:config:sites
}

--httpd:config:chmod() {
    sudo mkdir -p /home/pma/public_html/tmp
    sudo rm -rf /home/pma/public_html/config.inc.php
    sudo ln $_HTTPDDIR/diepxuan.com/config.inc.php /home/pma/public_html/
    sudo chmod -R 777 /home/pma/public_html/tmp

    sudo chown -R :www-data /home/*/public_html/
}

--httpd:config:sites() {
    # CREATE ductn SITE
    ###################
    #shellcheck disable=SC2002
    cat $_HTTPDDIR/httpd.conf | sudo tee /etc/apache2/sites-available/ductn.conf
    printf "\n\n" | sudo tee -a /etc/apache2/sites-available/ductn.conf
    # find $_HTTPDDIR/*/httpd.conf $_HTTPDDIR/*/httpd.conf.d/ -type f -exec cat {} \; | sudo tee -a /etc/apache2/sites-available/ductn.conf
    find $_HTTPDDIR/*/httpd.conf $_HTTPDDIR/*/httpd.conf.d/*.conf -type f | sort -n | xargs cat | sudo tee -a /etc/apache2/sites-available/ductn.conf
}

_DUCTN_COMMANDS+=("httpd:restart")
--httpd:restart() {
    --httpd:config $@
    sudo service apache2 restart
}
#!/usr/bin/env bash
#!/bin/bash

_IP_EXTEND=

_DUCTN_COMMANDS+=("ip:wan")
--ip:wan() {

    # IPANY="$(dig @ns1.google.com -t txt o-o.myaddr.l.google.com +short | tr -d \")"
    # GOOGv4="$(dig -4 @ns1.google.com -t txt o-o.myaddr.l.google.com +short | tr -d \")"
    # GOOGv6="$(dig -6 @ns1.google.com -t txt o-o.myaddr.l.google.com +short | tr -d \")"
    # AKAMv4="$(dig -4 @ns1-1.akamaitech.net -t a whoami.akamai.net +short)"
    # CSCOv4="$(dig -4 @resolver1.opendns.com -t a myip.opendns.com +short)"
    # CSCOv6="$(dig -6 @resolver1.opendns.com -t aaaa myip.opendns.com +short)"
    # printf '$GOOG:\t%s\t%s\t%s\n' "${IPANY}" "${GOOGv4}" "${GOOGv6}"
    # printf '$AKAM:\t%s\n$CSCO:\t%s\t%s\n' "${AKAMv4}" "${CSCOv4}" "${CSCOv6}"

    # if [[ -z ${_IP_EXTEND+x} ]]; then continue; else
    #     # _IP_EXTEND=$(dig @resolver4.opendns.com myip.opendns.com +short)
    #     _IP_EXTEND=$(dig -4 @ns1.google.com -t txt o-o.myaddr.l.google.com +short | tr -d \")
    # fi

    [[ -z "$_IP_EXTEND" ]] && _IP_EXTEND="$(dig -4 @ns1.google.com -t txt o-o.myaddr.l.google.com +short | tr -d \" 2>/dev/null)"
    echo $(--ip:valid $_IP_EXTEND)
}

--ip:wanv4() {
    dig @resolver4.opendns.com myip.opendns.com +short -4
}

--ip:wanv6() {
    dig @resolver1.ipv6-sandbox.opendns.com AAAA myip.opendns.com +short -6
}

_DUCTN_COMMANDS+=("ip:local")
--ip:local() {
    hostname -I | awk '{print $1}'
}

--ip:valid() {
    _IP=$@
    if expr "$_IP" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
        echo $_IP
        exit 0
    else
        echo $(--ip:local)
        exit 1
    fi
}

# _DUCTN_COMMANDS+=("ip:check")
--ip:check() {
    # Specify DNS server
    dnsserver="8.8.8.8"
    # function to get IP address
    function get_ipaddr {
        ip_address=""
        # A and AAA record for IPv4 and IPv6, respectively
        # $1 stands for first argument
        if [ -n "$1" ]; then
            hostname="${1}"
            if [ -z "query_type" ]; then
                query_type="A"
            fi
            # use host command for DNS lookup operations
            host -t ${query_type} ${hostname} ${dnsserver} &>/dev/null
            if [[ "$?" -eq "0" ]]; then
                # get ip address
                ip_address="$(host -t ${query_type} ${hostname} ${dnsserver} | awk '/has.*address/{print $NF; exit}')"
            else
                exit 1
            fi
        else
            exit 2
        fi
        # display ip
        echo $ip_address
    }
    hostname="$(--host:fullname)"
    for query in "A-IPv4" "AAAA-IPv6"; do
        query_type="$(printf $query | cut -d- -f 1)"
        ipversion="$(printf $query | cut -d- -f 2)"
        address="$(get_ipaddr ${hostname})"
        if [ "$?" -eq "0" ]; then
            if [ -n "${address}" ]; then
                echo "The ${ipversion} adress of the Hostname ${hostname} is: $address"
            fi
        else
            echo "An error occurred"
        fi
    done
}
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("log:watch")
--log:watch() {
    # ssh dx3.diepxuan.com "sudo tail -f /var/log/syslog" &
    # ssh dx1.diepxuan.com "sudo tail -f /var/log/syslog"
    sudo tail -f /var/log/*log /var/opt/mssql/log/errorlog
}

_DUCTN_COMMANDS+=("log:watch:service")
--log:watch:service() {
    sudo journalctl -u "$@".service -f
}

_DUCTN_COMMANDS+=("log:cleanup")
--log:cleanup() {

    # #!/bin/sh
    # if [ -d "/var/opt/mssql/log" ]; then
    #     sudo find /var/opt/mssql/log -type f -regex ".*\.gz$" -delete
    #     sudo find /var/opt/mssql/log -type f -regex ".*\.[0-9]$" -delete
    #     logs=$(sudo find /var/opt/mssql/log -type f)
    #     for i in $logs; do
    #         sudo truncate -s 0 $i
    #     done
    # fi

    #!/bin/sh

    # Check the Drive Space Used by Cached Files
    # du -sh /var/cache/apt/archives

    # Clean all the log file
    # for logs in `find /var/log -type f`;  do > $logs; done

    logs=$(sudo find /var/log -type f)
    for i in $logs; do
        sudo truncate -s 0 $i
    done

    #Getting rid of partial packages
    # sudo apt-get clean && sudo apt-get autoclean
    # apt-get remove --purge -y software-properties-common

    #Getting rid of no longer required packages
    # sudo apt-get autoremove -y

    #Getting rid of orphaned packages
    # deborphan | xargs sudo apt-get -y remove --purge

    #Free up space by clean out the cached packages
    # apt-get clean

    # Remove the Trash
    sudo rm -rf /home/*/.local/share/Trash/*/**
    sudo rm -rf /root/.local/share/Trash/*/**

    # Remove Man
    sudo rm -rf /usr/share/man/??
    sudo rm -rf /usr/share/man/??_*

    #Delete all .gz and rotated file
    # sudo find /var/log -type f -regex ".*\.gz$" | xargs sudo rm -Rf
    # sudo find /var/log -type f -regex ".*\.[0-9]$" | xargs sudo rm -Rf
    sudo find /var/log /var/opt/mssql/log -type f -regex ".*\.gz$" -delete
    sudo find /var/log /var/opt/mssql/log -type f -regex ".*\.[0-9]*$" -delete

    #Cleaning the old kernels
    # dpkg-query -l|grep linux-im*
    #dpkg-query -l |grep linux-im*|awk '{print $2}'
    # apt-get purge $(dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | head -n -1) --assume-yes
    # apt-get install linux-headers-`uname -r|cut -d'-' -f3`-`uname -r|cut -d'-' -f4`

    #Cleaning is completed
    --debug "Cleaning is completed"
}

_DUCTN_COMMANDS+=("log:config")
--log:config() {
    sudo truncate -s 0 /etc/logrotate.d/ductn
    --log:config:store
    --log:config:mssql

    sudo logrotate -f /etc/logrotate.d/ductn
    [[ $(--sys:env:dev) -eq 1 ]] && sudo cat /var/lib/logrotate/status
}

--log:config:store() {
    if id "store" &>/dev/null; then
        echo "/home/store/public_html/var/log/*.log {
    su store www-data
    size 1M
    copytruncate
    rotate 1
}
" | sudo tee --append /etc/logrotate.d/ductn >/dev/null
    fi
}

--log:config:mssql() {
    if id "mssql" &>/dev/null; then
        echo "/var/opt/mssql/log/errorlog /var/opt/mssql/log/*.log {
    su mssql mssql
    size 10M
    copytruncate
    missingok
    rotate 1
}
" | sudo tee --append /etc/logrotate.d/ductn >/dev/null
    fi

}
#!/usr/bin/env bash
#!/bin/bash

--sqlsrv:apt:install() {
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    # sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2019.list)"
    # sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/mssql-server-2019.list)"
    sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2019.list)"
    # sudo apt update
}

--sqlsrv:ad:spn() {
    # From DC

    # Create User
    # Import-Module ActiveDirectory
    # New-ADUser mssql -AccountPassword (Read-Host -AsSecureString "Enter Password") -PasswordNeverExpires $true -Enabled $true
    # Properties -> Accounts -> Account options: -> checked
    # - This account supports Kerberos AES 128 bit encryption
    # - This account supports Kerberos AES 256 bit encryption

    # create SPN
    setspn -A MSSQLSvc/dc3.diepxuan.com:1433 mssql
    setspn -A MSSQLSvc/dx3:1433 mssql

    # From SqlSrv Host
    kinit Administrator@DIEPXUAN.COM
    kvno Administrator@DIEPXUAN.COM
    kvno MSSQLSvc/dx3:1433@DIEPXUAN.COM
    # MSSQLSvc/dx3:1433@DIEPXUAN.COM: kvno = 2

    # From DC
    # Create mssql.keytab
    ktpass /princ MSSQLSvc/dc3.diepxuan.com:1433@DIEPXUAN.COM /ptype KRB5_NT_PRINCIPAL /crypto aes256-sha1 /mapuser mssql@diepxuan.com /out mssql.keytab -setpass -setupn /kvno 2 /pass Ductn@7691
    ktpass /princ MSSQLSvc/dc3.diepxuan.com:1433@DIEPXUAN.COM /ptype KRB5_NT_PRINCIPAL /crypto rc4-hmac-nt /mapuser mssql@diepxuan.com /in mssql.keytab /out mssql.keytab -setpass -setupn /kvno 2 /pass Ductn@7691

    ktpass /princ MSSQLSvc/dx3:1433@DIEPXUAN.COM /ptype KRB5_NT_PRINCIPAL /crypto aes256-sha1 /mapuser mssql@diepxuan.com /in mssql.keytab /out mssql.keytab -setpass -setupn /kvno 2 /pass Ductn@7691
    ktpass /princ MSSQLSvc/dx3:1433@DIEPXUAN.COM /ptype KRB5_NT_PRINCIPAL /crypto rc4-hmac-nt /mapuser mssql@diepxuan.com /in mssql.keytab /out mssql.keytab -setpass -setupn /kvno 2 /pass Ductn@7691

    ktpass /princ mssql@DIEPXUAN.COM /ptype KRB5_NT_PRINCIPAL /crypto aes256-sha1 /mapuser mssql@diepxuan.com /in mssql.keytab /out mssql.keytab -setpass -setupn /kvno 2 /pass Ductn@7691
    ktpass /princ mssql@DIEPXUAN.COM /ptype KRB5_NT_PRINCIPAL /crypto rc4-hmac-nt /mapuser mssql@diepxuan.com /in mssql.keytab /out mssql.keytab -setpass -setupn /kvno 2 /pass Ductn@7691
    # Or from SqlSrv Host
    sudo ktutil
    ktutil: addent -password -p MSSQLSvc/dc3.diepxuan.com:1433@DIEPXUAN.COM -k 2 -e aes256-cts-hmac-sha1-96
    ktutil: addent -password -p MSSQLSvc/dc3.diepxuan.com:1433@DIEPXUAN.COM -k 2 -e rc4-hmac
    ktutil: addent -password -p MSSQLSvc/dx3:1433@DIEPXUAN.COM -k 2 -e aes256-cts-hmac-sha1-96
    ktutil: addent -password -p MSSQLSvc/dx3:1433@DIEPXUAN.COM -k 2 -e rc4-hmac
    ktutil: addent -password -p mssql@DIEPXUAN.COM -k 2 -e aes256-cts-hmac-sha1-96
    ktutil: addent -password -p mssql@DIEPXUAN.COM -k 2 -e rc4-hmac
    ktutil: wkt /var/opt/mssql/secrets/mssql.keytab
    ktutil: quit

    # mssql.keytab
    # Copy to SqlSrv Host under the folder /var/opt/mssql/secrets

    # From SqlSrv Host
    sudo chown mssql:mssql /var/opt/mssql/secrets/mssql.keytab
    sudo chmod 400 /var/opt/mssql/secrets/mssql.keytab
    sudo mssql-conf set network.privilegedadaccount mssql
    sudo /opt/mssql/bin/mssql-conf set network.kerberoskeytabfile /var/opt/mssql/secrets/mssql.keytab
    sudo systemctl restart mssql-server
}
#!/usr/bin/env bash
#!/bin/bash

#sudo apt install -y unixodbc tdsodbc php?.?-sybase &>/dev/null
#sudo phpenmod sybase

_DUCTN_COMMANDS+=("sqlsrv:php:install")
--sqlsrv:php:install() {
    # Install PHP and other required packages
    #########################################
    ductn php:apt:install
    sudo apt install -y php-dev php-xml -y

    # Install the ODBC Driver and SQL Command Line Utility for SQL Server
    #####################################################################
    ductn sqlsrv:apt:install

    # curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    # # curl https://packages.microsoft.com/config/ubuntu/19.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
    # curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
    # sudo apt update

    sudo ACCEPT_EULA=Y apt install msodbcsql17 mssql-tools locales unixodbc-dev -y
    # sudo ACCEPT_EULA=Y apt install unixodbc-dev -y
    sudo locale-gen en_US.utf8
    sudo update-locale
    #sqlcmd -S localhost -U sa -P yourpassword -Q "SELECT @@VERSION"
    #echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
    #source ~/.bashrc

    # Install the PHP Driver for SQL Server
    #######################################
    # sudo apt install php-pear gcc g++ make autoconf libc-dev pkg-config libxml2-dev -y
    sudo apt install php-pear -y
    sudo pecl channel-update pecl.php.net
    sudo pecl install sqlsrv pdo_sqlsrv
    # sudo pecl install sqlsrv-5.7.0preview pdo_sqlsrv-5.7.0preview
}

_DUCTN_COMMANDS+=("sqlsrv:php:enable")
--sqlsrv:php:enable() {
    --sqlsrv:php:disable
    # printf "priority=20\nextension=sqlsrv.so\n" | sudo tee /etc/php/5.6/mods-available/sqlsrv.ini
    # printf "priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee /etc/php/5.6/mods-available/pdo_sqlsrv.ini

    # printf "priority=20\nextension=sqlsrv.so\n" | sudo tee /etc/php/7.0/mods-available/sqlsrv.ini
    # printf "priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee /etc/php/7.0/mods-available/pdo_sqlsrv.ini

    # printf "priority=20\nextension=sqlsrv.so\n" | sudo tee /etc/php/7.1/mods-available/sqlsrv.ini
    # printf "priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee /etc/php/7.1/mods-available/pdo_sqlsrv.ini

    # printf "priority=20\nextension=sqlsrv.so\n" | sudo tee /etc/php/7.2/mods-available/sqlsrv.ini
    # printf "priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee /etc/php/7.2/mods-available/pdo_sqlsrv.ini

    # printf "priority=20\nextension=sqlsrv.so\n" | sudo tee /etc/php/7.3/mods-available/sqlsrv.ini
    # printf "priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee /etc/php/7.3/mods-available/pdo_sqlsrv.ini

    # printf "priority=20\nextension=sqlsrv.so\n" | sudo tee /etc/php/7.4/mods-available/sqlsrv.ini
    # printf "priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee /etc/php/7.4/mods-available/pdo_sqlsrv.ini

    # printf "; priority=20\nextension=sqlsrv.so\n" | sudo tee /etc/php/8.0/mods-available/sqlsrv.ini
    # printf "; priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee /etc/php/8.0/mods-available/pdo_sqlsrv.ini
    $(php --ini | grep "Configuration File (php.ini)" | sed -e "s|.*:\s*||" -e "s/\/cli$//")
    printf "priority=20\nextension=sqlsrv.so\n" | sudo tee $(php --ini | grep "Configuration File (php.ini)" | sed -e "s|.*:\s*||" -e "s/\/cli$//")/mods-available/sqlsrv.ini
    printf "priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee $(php --ini | grep "Configuration File (php.ini)" | sed -e "s|.*:\s*||" -e "s/\/cli$//")/mods-available/pdo_sqlsrv.ini

    # sudo phpenmod -v 8.0 sqlsrv pdo_sqlsrv
    sudo phpenmod sqlsrv pdo_sqlsrv

    #echo extension=sqlsrv.so | sudo tee -a `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/20-sqlsrv.ini
    #echo extension=pdo_sqlsrv.so | sudo tee -a `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini
}

_DUCTN_COMMANDS+=("sqlsrv:php:disable")
--sqlsrv:php:disable() {
    sudo phpdismod sqlsrv pdo_sqlsrv
    sudo /usr/sbin/service apache2 restart
}

_DUCTN_COMMANDS+=("mssql:php:install")
--mssql:php:install() {
    --sqlsrv:php:install
}

_DUCTN_COMMANDS+=("mssql:php:enable")
--mssql:php:enable() {
    --sqlsrv:php:enable
    sudo /usr/sbin/service apache2 start
}

_DUCTN_COMMANDS+=("mssql:php:disable")
--mssql:php:disable() {
    --sqlsrv:php:disable
}
#!/usr/bin/env bash
#!/bin/bash

--sqlsrv:apt:install() {
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    # sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2019.list)"
    # sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/mssql-server-2019.list)"
    sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2019.list)"
    # sudo apt update
}

_DUCTN_COMMANDS+=("sqlsrv:install")
--sqlsrv:install() {
    --sqlsrv:apt:install

    # Install SQL Server
    ####################
    sudo apt install -y mssql-server

    # Configration SQL Server
    ####################
    sudo /opt/mssql/bin/mssql-conf setup
}

_DUCTN_COMMANDS+=("mssql:install")
--mssql:install() {
    --sqlsrv:install
}

--sqlsrv:cron() {
    --sqlsrv:install
}
#!/usr/bin/env bash
#!/bin/bash

CERTDIR=/etc/mysql/certs/
_MYSQLDIR="$_LIBDIR/mysql"

_DUCTN_COMMANDS+=("mysql:setup")
--mysql:setup() {
    $_BASHDIR/ductn --swap --install
    sudo apt install -y --purge --auto-remove mysql-server
    # sudo mysql_secure_installation
}

_DUCTN_COMMANDS+=("mysql:ssl:enable")
--mysql:ssl:enable() {
    mkdir $CERTDIR
    # openssl genrsa 4096 | sudo tee ca-key.pem
    sudo cp $_MYSQLDIR/ssl/*.pem $CERTDIR
    sudo openssl req -new -x509 -nodes -days 365000 -key $CERTDIR/ca-key.pem -out $CERTDIR/ca-cert.pem

    sudo openssl req -newkey rsa:2048 -days 365000 -nodes -keyout $CERTDIR/server-key.pem -out $CERTDIR/server-req.pem
    sudo openssl rsa -in $CERTDIR/server-key.pem -out $CERTDIR/server-key.pem
    sudo openssl x509 -req -in $CERTDIR/server-req.pem -days 365000 -CA $CERTDIR/ca-cert.pem -CAkey $CERTDIR/ca-key.pem -set_serial 01 -out $CERTDIR/server-cert.pem

    sudo openssl req -newkey rsa:2048 -days 365000 -nodes -keyout $CERTDIR/client-key.pem -out $CERTDIR/client-req.pem
    sudo openssl rsa -in $CERTDIR/client-key.pem -out $CERTDIR/client-key.pem
    sudo openssl x509 -req -in $CERTDIR/client-req.pem -days 365000 -CA $CERTDIR/ca-cert.pem -CAkey $CERTDIR/ca-key.pem -set_serial 01 -out $CERTDIR/client-cert.pem

    openssl verify -CAfile $CERTDIR/ca-cert.pem $CERTDIR/server-cert.pem $CERTDIR/client-cert.pem
    cat $_MYSQLDIR/ssl/10-ssl.cnf | sudo tee /etc/mysql/conf.d/10-ssl.cnf

    sudo chown -R mysql:root $CERTDIR
}
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("php:composer:install")
--php:composer:install() {
    cd ~
    curl -sS https://getcomposer.org/installer -o composer-setup.php
    HASH=$(curl -sS https://composer.github.io/installer.sig)
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    php -r "unlink('composer-setup.php');"
    rm -rf composer-setup.php
}
#!/usr/bin/env bash
#!/bin/bash

--php:apt:install() {
    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt update
    # sudo apt install -y php-dev php-xml -y --allow-unauthenticated &>/dev/null
}

_DUCTN_COMMANDS+=("php:install")
--php:install() {
    --php:apt:install

    #!/bin/bash

    # sudo add-apt-repository ppa:ondrej/php
    # sudo apt update
    # sudo apt install libapache2-mod-php?.? -y --purge --auto-remove
    # sudo update-alternatives --config php

    #sudo update-alternatives --set php /usr/bin/php5.6
    #sudo update-alternatives --set phar /usr/bin/phar5.6
    #sudo update-alternatives --set phar.phar /usr/bin/phar.phar5.6
    #sudo update-alternatives --set phpize /usr/bin/phpize5.6
    #sudo update-alternatives --set php-config /usr/bin/php-config5.6

    # INSTALL PHP MODULES
    ########################
    # sudo apt install phpmd -y --purge --auto-remove &>/dev/null
    # sudo apt install composer -y --purge --auto-remove &>/dev/null

    # sudo apt install -y libapache2-mod-php?.? php?.? php?.?-mysql php?.?-mbstring php?.?-mysqli php?.?-intl php?.?-curl php?.?-gd php?.?-mcrypt php?.?-soap php?.?-dom php?.?-xml php?.?-zip php?.?-bcmath php?.?-imagick &>/dev/null
    # sudo apt install -y php?.?-mongodb &>/dev/null
    # ductn_php_mssql
    # sudo service apache2 restart
}

_DUCTN_COMMANDS+=("php:phpcsfixer:install")
--php:phpcsfixer:install() {
    cd ~
    curl -sS https://cs.symfony.com/download/php-cs-fixer-v3.phar -o php-cs-fixer
    if [ "$(whoami)" = "ductn" ]; then
        chmod +x php-cs-fixer
        sudo mv php-cs-fixer /usr/local/bin/php-cs-fixer
        sudo chown root:root /usr/local/bin/php-cs-fixer
    fi
}
#!/usr/bin/env bash
#!/bin/bash

####################################
#
# SSH
#
####################################
# Create PEM file
# ##############################
#
# openssl rsa -in id_rsa -outform PEM -out id_rsa.pem
# openssl x509 -outform der -in id_rsa.pem -out id_rsa.crt

# Change passphrase
# ##############################
# SYNOPSIS
# #ssh-keygen [-q] [-b bits] -t type [-N new_passphrase] [-C comment] [-f output_keyfile]
# #ssh-keygen -p [-P old_passphrase] [-N new_passphrase] [-f keyfile]
# #-f filename Specifies the filename of the key file.
# -N new_passphrase     Provides the new passphrase.
# -P passphrase         Provides the (old) passphrase.
# -p                    Requests changing the passphrase of a private key file instead of
#                       creating a new private key.  The program will prompt for the file
#                       containing the private key, for the old passphrase, and twice for
#                       the new passphrase.
#
# ssh-keygen -t rsa -y > ~/.ssh/id_rsa.pub
# ssh-keygen -f id_rsa -p

# Setup
# ##############################
_DUCTN_COMMANDS+=("ssh:install")
--ssh:install() {
    # ssh config
    cat /var/www/base/ssh/config >~/.ssh/config
    printf "\n\n" >>~/.ssh/config
    find /var/www/base/ssh/config.d/*.conf -type f -exec cat {} \; -exec printf "\n\n" \; >>~/.ssh/config

    # ssh private key
    cat /var/www/base/ssh/id_rsa >~/.ssh/id_rsa
    # cat /var/www/base/ssh/gss > ~/.ssh/gss
    # cat /var/www/base/ssh/tci > ~/.ssh/tci
    # cat /var/www/base/ssh/gem > ~/.ssh/gem

    # ssh public key
    ssh-keygen -f ~/.ssh/id_rsa -y >~/.ssh/id_rsa.pub
    # ssh-keygen -f ~/.ssh/gss -y > ~/.ssh/gss.pub
    # ssh-keygen -f ~/.ssh/tci -y > ~/.ssh/tci.pub
    # ssh-keygen -f ~/.ssh/gem -y > ~/.ssh/gem.pub
    --ssh:permision

    # ssh-copy-id user@123.45.56.78

    # cat /var/www/base/ssh/id_rsa        | ssh dx1.diepxuan.com "cat > ~/.ssh/id_rsa"
    # cat /var/www/base/ssh/id_rsa.pub    | ssh dx1.diepxuan.com "cat > ~/.ssh/id_rsa.pub"
    # ssh dx1.diepxuan.com "chmod 600 ~/.ssh/*"
}

--ssh:permision() {
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/*
}

_DUCTN_COMMANDS+=("ssh:copy")
--ssh:copy() {
    cat /var/www/base/ssh/id_rsa | ssh ${1} "cat > ~/.ssh/id_rsa"
    ssh ${1} "chmod 600 ~/.ssh/*"
    ssh ${1} "ssh-keygen -f ~/.ssh/id_rsa -y >~/.ssh/id_rsa.pub"
    # cat /var/www/base/ssh/id_rsa.pub | ssh ${1} "cat > ~/.ssh/id_rsa.pub"
}
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("ssl:install")
--ssl:install() {
    sudo apt install software-properties-common -y --purge --auto-remove
    # sudo add-apt-repository universe
    # sudo add-apt-repository ppa:certbot/certbot
    sudo apt update
    sudo apt install -y --purge --auto-remove python3-pip
    # sudo pip3 install certbot certbot-dns-cloudflare
    sudo apt install -y --purge --auto-remove certbot python3-certbot-dns-cloudflare
}

_DUCTN_COMMANDS+=("ssl:configure")
--ssl:configure() { --ssl:setup; }

--ssl:setup() {

    #sudo certbot certonly --apache \
    #  --expand \
    #  --no-redirect \
    #  --keep-until-expiring \
    #  --break-my-certs \
    #  --pre-hook /var/www/base/bash/certbot/authenticator.sh \
    #  -m caothu91@gmail.com \
    #  --server https://acme-v02.api.letsencrypt.org/directory

    #_certbot solzatech.com,www.solzatech.com
    # _certbot diepxuan.com,www.diepxuan.com,luong.diepxuan.com,pma.diepxuan.com,cloud.diepxuan.com,work.diepxuan.com,shop.diepxuan.com
    --ssl:certbot diepxuan.com,*.diepxuan.com
    --ssl:certbot vps.diepxuan.com,*.vps.diepxuan.com

    sudo service apache2 restart

    #  sudo cat /etc/letsencrypt/live/mail.diepxuan.com/fullchain.pem | ssh server3.diepxuan.com "sudo tee /etc/letsencrypt/live/mail.diepxuan.com/fullchain.pem"
    #  sudo cat /etc/letsencrypt/live/mail.diepxuan.com/privkey.pem | ssh server3.diepxuan.com "sudo tee /etc/letsencrypt/live/mail.diepxuan.com/privkey.pem"

    # sudo scp -r /etc/letsencrypt/live/* dx3.diepxuan.com:/etc/letsencrypt/live/
}

--ssl:certbot() {

    chmod 600 /var/www/base/bash/certbot/cloudflare.ini

    sudo certbot certonly \
        --expand \
        --keep-until-expiring \
        --dns-cloudflare \
        --dns-cloudflare-credentials /var/www/base/bash/certbot/cloudflare.ini \
        --agree-tos \
        --email caothu91@gmail.com \
        --eff-email \
        -d $@
}

--ssl:pull() {
    sudo mkdir -p /etc/letsencrypt/live/diepxuan.com/
    ssh $@ "sudo cat /etc/letsencrypt/live/diepxuan.com/cert.pem" | sudo tee /etc/letsencrypt/live/diepxuan.com/cert.pem
    ssh $@ "sudo cat /etc/letsencrypt/live/diepxuan.com/chain.pem" | sudo tee /etc/letsencrypt/live/diepxuan.com/chain.pem
    ssh $@ "sudo cat /etc/letsencrypt/live/diepxuan.com/fullchain.pem" | sudo tee /etc/letsencrypt/live/diepxuan.com/fullchain.pem
    ssh $@ "sudo cat /etc/letsencrypt/live/diepxuan.com/privkey.pem" | sudo tee /etc/letsencrypt/live/diepxuan.com/privkey.pem
}

--ssl:push() {
    sudo cat /etc/letsencrypt/live/diepxuan.com/cert.pem | ssh ${@} "sudo tee /etc/letsencrypt/live/diepxuan.com/cert.pem"
    sudo cat /etc/letsencrypt/live/diepxuan.com/chain.pem | ssh ${@} "sudo tee /etc/letsencrypt/live/diepxuan.com/chain.pem"
    sudo cat /etc/letsencrypt/live/diepxuan.com/fullchain.pem | ssh ${@} "sudo tee /etc/letsencrypt/live/diepxuan.com/fullchain.pem"
    sudo cat /etc/letsencrypt/live/diepxuan.com/privkey.pem | ssh ${@} "sudo tee /etc/letsencrypt/live/diepxuan.com/privkey.pem"
}

--ssl:upload() {
    --push
}
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("swap:remove")
--swap:remove() {
    sudo swapoff -v /swapfile
    sudo rm /swapfile
    exit 0
}

_DUCTN_COMMANDS+=("swap:install")
--swap:install() {
    --swap:remove
    sudo rm -rf /swapfile
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
}

# free -m
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:ad:install")
--sys:ad:install() {
    sudo apt install -y realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit

    realm discover diepxuan.com
    # Join Domain
    --sys:ad:krb5conf
    sudo realm join -U Administrator diepxuan.com

    # Domain User Config
    --sys:ad:mkhomedir
    --sys:ad:sssd
    sudo systemctl restart sssd

    # Domain User Login
    --sys:ad:sudoers
    --sys:ad:sshd
}

--sys:ad:krb5conf() {
    --force() {
        sudo rm -rf /etc/krb5.conf
    }

    $@
    if [[ -f /etc/krb5.conf ]]; then
        sudo sed -i 's/.*rdns.*/rdns = false/' /etc/krb5.conf
    else
        echo "[logging]
default = FILE:/var/log/krb5libs.log
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmind.log

[libdefaults]
udp_preference_limit = 0
dns_lookup_realm = true
dns_lookup_kdc = true
ticket_lifetime = 24h
renew_lifetime = 7d
forwardable = true
rdns = false
default_realm = DIEPXUAN.COM
default_ccache_name = KEYRING:persistent:%{uid}
# default_ccache_name = FILE:/tmp/krb5cc_%{uid}

[realms]
DIEPXUAN.COM = {
    kdc = DC.DIEPXUAN.COM:88
    admin_server = DC.DIEPXUAN.COM
    default_domain = DIEPXUAN.COM
}

[domain_realm]
diepxuan.com = DIEPXUAN.COM
.diepxuan.com = DIEPXUAN.COM
" | sudo tee /etc/krb5.conf >/dev/null
    fi
}

--sys:ad:mkhomedir() {
    echo "Name: Create home directory on login
Default: yes
Priority: 900
Session-Type: Additional
Session:
        optional                        pam_mkhomedir.so skel=/etc/skel umask=077" | sudo tee /usr/share/pam-configs/mkhomedir >/dev/null
    sudo pam-auth-update --enable mkhomedir
}

--sys:ad:sssd() {
    # access_provider = ad
    sudo sed -i 's/.*use_fully_qualified_names.*/use_fully_qualified_names = True/' /etc/sssd/sssd.conf
    sudo sed -i 's/.*fallback_homedir.*/fallback_homedir = \/home\/%d\/%u/' /etc/sssd/sssd.conf
    sudo systemctl restart sssd
}

--sys:ad:sudoers() {
    sudo realm permit 'Domain Users' 'Users'
    if [ "$(whoami)" = "ductn" ]; then
        echo "
%quantri@diepxuan.com           ALL=(ALL) NOPASSWD:ALL
%Domain\ Admins@diepxuan.com    ALL=(ALL) NOPASSWD:ALL

%DIEPXUAN.COM\\Domain\ Admins   ALL=(ALL) NOPASSWD:ALL
%DIEPXUAN.COM\\Quantri          ALL=(ALL) NOPASSWD:ALL

%Domain\ Admins                 ALL=(ALL) NOPASSWD:ALL
%Quantri                        ALL=(ALL) NOPASSWD:ALL
" | sudo tee /etc/sudoers.d/91-domain-admins >/dev/null
    fi

}

--sys:ad:sshd() {
    # /etc/ssh/sshd_config.d/
    echo "# Settings that override the global settings for matching groups only
# AllowGroups diepxuan.com\Quantri
Match Group Quantri
    PasswordAuthentication yes
" | sudo tee /etc/ssh/sshd_config.d/91-domain-admins.conf >/dev/null
    sudo sed -i 's/.*PubkeyAuthentication/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sudo sed -i 's/.*PasswordAuthentication/PasswordAuthentication no/' /etc/ssh/sshd_config

    sudo sed -i 's/.*UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

    sudo sed -i 's/.*ChallengeResponseAuthentication\ yes/ChallengeResponseAuthentication\ no/' /etc/ssh/sshd_config
    sudo sed -i 's/.*GSSAPIAuthentication.*/#GSSAPIAuthenticationc no/' /etc/ssh/sshd_config
    sudo sed -i 's/.*GSSAPICleanupCredentials.*/#GSSAPICleanupCredentials yes/' /etc/ssh/sshd_config

    sudo sed -i 's/.*KerberosAuthentication.*/#KerberosAuthentication yes/' /etc/ssh/sshd_config
    sudo sed -i 's/.*KerberosOrLocalPasswd.*/#KerberosOrLocalPasswd yes/' /etc/ssh/sshd_config

    sudo service sshd restart
}
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:apt:fix")
--sys:apt:fix() {
    --apt:fix
}

_DUCTN_COMMANDS+=("sys:apt:check")
--sys:apt:check() {
    dpkg -s $1 2>/dev/null | grep 'install ok installed' >/dev/null 2>&1
    if [ $? != 0 ]; then
        echo 0
    else
        echo 1
    fi

    # REQUIRED_PKG=$1
    # PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG | grep "install ok installed")
    # # echo Checking for $REQUIRED_PKG: $PKG_OK
    # if [ "" = "$PKG_OK" ]; then
    #     #     echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
    #     #     sudo apt-get --yes install $REQUIRED_PKG
    #     echo 0
    # else
    #     echo 1
    # fi

}

_DUCTN_COMMANDS+=("sys:apt:install")
--sys:apt:install() {
    if [[ "$(--sys:apt:check $@)" -eq 0 ]]; then
        sudo apt install $@ -y --purge --auto-remove
    fi
}

_DUCTN_COMMANDS+=("sys:apt:remove")
--sys:apt:remove() {
    sudo apt remove $@ -y --purge --auto-remove
}

_DUCTN_COMMANDS+=("sys:apt:uninstall")
--sys:apt:uninstall() {
    --sys:apt:remove $@
}

--apt:fix() {
    #!/bin/bash

    sudo killall apt-get
    sudo killall apt

    sudo rm /var/lib/apt/lists/lock
    sudo rm /var/cache/apt/archives/lock
    sudo rm /var/lib/dpkg/lock
    sudo rm /var/lib/dpkg/lock-frontend

    sudo dpkg --configure -a
}
#!/usr/bin/env bash
#!/bin/bash

--sys:base:upgrade() {
    if [[ $(--sys:env:dev) -eq 1 ]]; then
        --sys:base:dev
    else
        --sys:base:bin
    fi
    ductn sys:init
    ductn sys:service:re-install
    exit 0
}

--sys:base:dev() {
    mkdir -p "$_BASEDIR"
    cd "$_BASEDIR"
    git fetch -ap
    git reset --hard origin/master
    --git:configure
    --sys:env DEV 1
}

--sys:base:bin() {
    mkdir -p "$_BASEDIR"
    cd "$_BASEDIR"
    git archive --remote=git@bitbucket.org:DXVN/code.git master | tar -x -C "${_BASEDIR}"
}

_DUCTN_COMMANDS+=("sys:selfupdate" "selfupdate" "self-update")
--selfupdate() { --sys:selfupdate; }
--self-update() { --sys:selfupdate; }
--sys:selfupdate() {
    if [[ $(--version:islatest) -eq 0 ]]; then
        --sys:base:upgrade
    fi
}
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:completion" "sys:completion:commands")

--sys:completion() {
    [ $(--sys:completion:exists ductn) ] && --sys:completion:base
    [ $(--sys:completion:exists magerun) ] && --sys:completion:magerun
    [ $(--sys:completion:exists magerun2) ] && --sys:completion:magerun2
    [ $(--sys:completion:exists wp) ] && --sys:completion:wp
    [ $(--sys:completion:exists angular) ] && --sys:completion:angular
}

--sys:completion:base() {
    # bash completion for the `ductn cli` command
    # ################################################################
    if ! shopt -oq posix; then
        if [[ -f /var/www/base/bash/completion/ductn.sh ]]; then
            echo /var/www/base/bash/completion/ductn.sh
        elif [[ -f $HOME/.completion/ductn.sh ]]; then
            echo $HOME/.completion/ductn.sh
        fi
    fi
}

--sys:completion:magerun() {
    # completion magerun
    # ################################################################
    # https://raw.githubusercontent.com/netz98/n98-magerun/develop/res/autocompletion/bash/n98-magerun.phar.bash
    if ! shopt -oq posix; then
        if [[ -f /var/www/base/bash/completion/magerun.sh ]]; then
            echo /var/www/base/bash/completion/magerun.sh
        elif [[ -f $HOME/.completion/magerun.sh ]]; then
            echo $HOME/.completion/magerun.sh
        fi
    fi
}
--sys:completion:magerun2() {
    # completion magerun2
    # ################################################################
    # https://raw.githubusercontent.com/netz98/n98-magerun2/develop/res/autocompletion/bash/n98-magerun2.phar.bash
    if ! shopt -oq posix; then
        if [[ -f /var/www/base/bash/completion/magerun2.sh ]]; then
            echo /var/www/base/bash/completion/magerun2.sh
        elif [[ -f $HOME/.completion/magerun2.sh ]]; then
            echo $HOME/.completion/magerun2.sh
        fi
    fi
}

--sys:completion:wp() {
    # bash completion for the `wp` command
    # ################################################################
    if ! shopt -oq posix; then
        if [[ -f /var/www/base/bash/completion/wp.sh ]]; then
            echo /var/www/base/bash/completion/wp.sh
        elif [[ -f $HOME/.completion/wp.sh ]]; then
            echo $HOME/.completion/wp.sh
        fi
    fi
}

--sys:completion:angular() {
    # bash completion for the `angular cli` command
    # ################################################################
    if ! shopt -oq posix; then
        if [[ -f /var/www/base/bash/completion/angular2.sh ]]; then
            echo /var/www/base/bash/completion/angular2.sh
        elif [[ -f $HOME/.completion/angular2.sh ]]; then
            echo $HOME/.completion/angular2.sh
        fi
    fi
}

--sys:completion:commands() {
    echo "${_DUCTN_COMMANDS[*]}"
}

--sys:completion:exists() {
    [ ! -x "$(command -v $@)" ] && echo 0 || echo 1
}
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:dhcp:setup")
--sys:dhcp:setup() {
    if [ $(--host:is_server) = 1 ]; then
        --sys:apt:install isc-dhcp-server

        --sys:dhcp:config
    fi
}

--sys:dhcp:config() {
    _DHCP_DEFAULT=/etc/default/isc-dhcp-server

    ### /etc/default/isc-dhcp-server
    sudo sed -i 's/INTERFACES=.*/INTERFACES="vmbr1"/' $_DHCP_DEFAULT >/dev/null
    sudo sed -i 's/INTERFACESv4=.*/INTERFACESv4="vmbr1"/' $_DHCP_DEFAULT >/dev/null
    # sudo sed -i 's/INTERFACESv6=.*/INTERFACESv6="vmbr1"/' $_DHCP_DEFAULT >/dev/null

    ### /etc/dhcp/dhcpd.conf
    [ ! -f /etc/dhcp/dhcpd.conf.org ] && sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.org
    echo -e "$_DHCPD_CONF" | sudo tee /etc/dhcp/dhcpd.conf >/dev/null

    sudo killall dhcpd
    sudo rm -rf /var/run/dhcpd.pid
    --sys:service:restart isc-dhcp-server
}
_DHCPD_HOST=$(--host:name)
_DHCPD_HOST=${_DHCPD_HOST:3}
_DHCPD_CONF="option domain-name \"diepxuan.com\";
option domain-search \"diepxuan.com\";
option domain-name-servers 1.1.1.1, 10.0.1.10, 10.0.2.10;

default-lease-time 600;
max-lease-time 7200;

ddns-update-style none;
authoritative;

one-lease-per-client true;
deny duplicates;
update-conflict-detection false;

subnet 10.0.$_DHCPD_HOST.0 netmask 255.255.255.0 {
    pool {
        option domain-name-servers 1.1.1.1,10.0.1.10,10.0.2.10;
        range 10.0.$_DHCPD_HOST.150 10.0.$_DHCPD_HOST.199;
    }

    option domain-name-servers 1.1.1.1,10.0.1.10,10.0.2.10;

    option routers 10.0.$_DHCPD_HOST.1;
    option subnet-mask 255.255.255.0;

    ping-check true;
}

host dc1 {
    hardware ethernet ba:1f:4a:6a:63:a1;
    fixed-address 10.0.1.10;
    option host-name \"dc1\";
}

host dc2 {
    hardware ethernet 62:F0:9D:12:02:61;
    fixed-address 10.0.2.10;
    option host-name \"dc2\";
}

host sql1 {
    hardware ethernet ae:fa:53:5f:00:f1;
    fixed-address 10.0.1.11;
    option host-name \"sql1\";
}

host sql2 {
    hardware ethernet 16:13:D5:80:B3:58;
    fixed-address 10.0.2.11;
    option host-name \"sql2\";
}
"
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

--zfs:disk:list() {
    ls -alh /dev/disk/by-id/
    sudo zpool status
    sudo zpool list -v
}

--zfs:disk:offline() {
    # sudo zpool offline "POOLNAME" "HARD-DRIVE-ID or the whole path"
    # sudo zpool offline rpool ata-HITACHI_HUA722010ALA330_J80TS2LL
    sudo zpool offline rpool $@
}

--zfs:disk:replace() {
    sudo proxmox-boot-tool status
}
--zfs:disk:replace_disk() {
    --dlogger "replace_disk $_pool_name $_old_zfs_part $_new_zfs_part"
    _pool_name=$1
    _old_zfs_part=$2
    _new_zfs_part=$3
    sudo zpool replace -f $_pool_name $_old_zfs_part $_new_zfs_part
}

--zfs:disk:replace_boot_disk() {
    --dlogger "replace_boot_disk"
    # Copying the partition table, reissuing GUIDs and replacing the ZFS partition are the same.
    # To make the system bootable from the new disk, different steps are needed which depend on the bootloader in use.

    # sudo sgdisk /dev/disk/by-id/ata-TOSHIBA_MQ01ABD100_48MFT0FZT -R /dev/disk/by-id/ata-HGST_HTS721010A9E630_JR100XBN1LH00E
    # sudo sgdisk -G /dev/disk/by-id/ata-HGST_HTS721010A9E630_JR100XBN1LH00E
    # sudo zpool replace -f rpool /dev/disk/by-id/ata-HITACHI_HUA722010ALA330_J80TS2LL-part3 /dev/disk/by-id/ata-HGST_HTS721010A9E630_JR100XBN1LH00E-part3
}

--zfs:disk:format_boot_disk() {
    --dlogger "format_boot_disk"
    # ESP stands for EFI System Partition, which is setup as partition #2 on bootable disks setup by the Proxmox

    # sudo proxmox-boot-tool format /dev/sdb2
}
#!/usr/bin/env bash
#!/bin/bash

DDNS_DOMAINS="$DDNS_DOMAINS dc1.diepxuan.com dc2.diepxuan.com dc3.diepxuan.com dx1.diepxuan.com dx2.diepxuan.com dx3.diepxuan.com sql1.diepxuan.com sql2.diepxuan.com"

_DUCTN_COMMANDS+=("sys:env")
--sys:env() {
    if [[ $# == 1 ]]; then
        case "$@" in
        domains | DDNS_DOMAINS)
            # echo hehe
            # echo -e "$(--sys:env:domains)"
            echo -e "$DDNS_DOMAINS" | xargs
            ;;
        NAT | nat)
            echo -e "$(--sys:env:multi NAT)"
            ;;
        *)
            echo -e "${!@}" | xargs
            ;;
        esac
    elif [[ $# > 1 ]]; then
        --sys:env:set $@
    fi
}

--sys:env:set() {
    _PARAM=$1
    _VALUE=""

    for val in "$@"; do
        if [[ ! $_PARAM == $val ]]; then
            [[ $_VALUE == "" ]] && _VALUE=$val || _VALUE="$_VALUE $val"
        fi
    done

    if [[ ! -n $(grep -P "$1" $_BASEDIR/.env) ]]; then
        echo "$_PARAM=\"$_VALUE\"" >>$_BASEDIR/.env
    else
        sed -i -E "s/$_PARAM=.*/$_PARAM=\"$_VALUE\"/" $_BASEDIR/.env
    fi
}

--sys:env:list() {
    IFS=', ' read -r -a array <<<$(--sys:env "$@")
    for item in "${array[@]}"; do
        echo $item
    done
}

--sys:env:domains() {
    for domain in $(--sys:env:list "DDNS_DOMAINS"); do
        echo $domain
    done
}

--sys:env:import() {
    if [[ -f $_BASEDIR/.env ]]; then

        # while read -r _env; do
        #     if [[ ! $_env =~ ^#.* ]] && [[ $_env == *'='* ]]; then
        #         # echo $_env
        #         $_env= $(echo $_env | xargs) 2>/dev/null
        #         IFS='=' read -r -a _array <<<$_env
        #         _PARAM=$(echo "${_array[0]}" | xargs)
        #         _VALUE="$(echo "${_array[1]}" | xargs)"
        #         # eval $_PARAM=$_VALUE
        #         eval "declare $_PARAM='$_VALUE'"
        #         # echo ${!_PARAM}
        #         # eval $_PARAM="$_VALUE"
        #         # echo "$_PARAM=$_VALUE"
        #     fi
        # done <"$_BASEDIR/.env"

        source $_BASEDIR/.env
    fi
}

--sys:env:multi() {
    _PARAM=$@
    _VALUE=()
    if [[ ! -z $_PARAM ]] && [[ -f $_BASEDIR/.env ]]; then
        while read -r _env; do
            if [[ $_env =~ ^$_PARAM* ]]; then
                # echo $_PARAM
                _env=${_env//"$_PARAM="/}
                _env=${_env//'"'/}
                echo $_env
            fi
        done <"$_BASEDIR/.env"
    fi
}

--sys:env:debug() {
    --sys:env DEBUG
}

--sys:env:dev() {
    --sys:env DEV
}
#!/usr/bin/env bash
#!/bin/bash

--test() {
    echo -e "ductn proccess version: $(--version)"
}
---T() { --test; }
--exists() {
    # nothing to do
    echo '' 1>&3
}
--do_no_thing() { --exists; }

--pwd() {
    echo $_BASEDIR
}

--logger() {
    logger "$@"
}

--echo() {
    echo -e $@ 2>/dev/null
}

--debug() {
    if [[ $(--sys:env:dev) -eq 1 ]]; then
        echo -e $@
    fi
}

--dlogger() {
    if [[ $(--sys:env:dev) -eq 1 ]]; then
        logger "$@"
    fi
}
#!/usr/bin/env bash
#!/bin/bash

ETC_HOSTS=/etc/hosts

# sed -i 's/var=.*/var=new_value/' file_name

_DUCTN_COMMANDS+=("sys:hosts:add")
--sys:hosts:add() {
    IP=$1
    HOSTNAME=$2

    HOSTS_LINE="$IP\t$HOSTNAME"

    if [[ ! -n $(grep -P "$IP[[:space:]]$HOSTNAME" $ETC_HOSTS) ]]; then
        echo -e $HOSTS_LINE | sudo tee -a /etc/hosts >/dev/null
    fi

    # [[ -n $(grep -P "$IP[[:space:]]$HOSTNAME" $ETC_HOSTS) ]] && echo ">> Hosts added: $(grep $HOSTNAME $ETC_HOSTS)" || echo "Failed to Add $HOSTNAME, Try again!"
}

_DUCTN_COMMANDS+=("sys:hosts:remove")
--sys:hosts:remove() {
    IP=$1
    HOSTNAME=$2

    sudo sed -i "/$HOSTNAME/d" $ETC_HOSTS
    # grep -P "pve2.vpn" | sudo tee $ETC_HOSTS

    # [[ -n "$(grep $HOSTNAME /etc/hosts)" ]] && echo ">> Hosts removed: $HOSTNAME" || echo "$HOSTNAME was not found!"
}

_DUCTN_COMMANDS+=("sys:hosts:domain")
--sys:hosts:domain() {
    IP=$(--ip:wan)
    HOSTNAME="$(--host:fullname) $(--host:name)"
    HOSTS_LINE="$IP\\t$HOSTNAME"
    echo -e $HOSTS_LINE
}

_DUCTN_COMMANDS+=("sys:hosts:update")
--sys:hosts:update() {
    sed -i 's/var=.*/var=new_value/' ${ETC_HOSTS}
}
#!/usr/bin/env bash
#!/bin/bash

--sys:service:httpd() {
    if [ "$(--sys:service:isactive apache2)" == "failed" ]; then
        --swap:install
        --log:cleanup
        --sys:service:restart apache2
    fi

    # sudo /usr/sbin/service apache2 status | grep 'active' >/dev/null 2>&1
    # if [ $? != 0 ]; then
    #     sudo /usr/sbin/service apache2 start
    # fi
}

--sys:service:mysql() {
    if [ "$(--sys:service:isactive mysql)" == "failed" ]; then
        --swap:install
        --log:cleanup
        --sys:service:restart mysql
    fi

    # sudo /usr/sbin/service mysql status | grep 'active' >/dev/null 2>&1
    # if [ $? != 0 ]; then
    #     --swap:install
    #     --log:cleanup
    #     sudo /usr/sbin/service mysql start
    # fi
}

--sys:service:mssql() {
    if [ "$(--sys:service:isactive mssql-server)" == "failed" ]; then
        --swap:install
        --log:cleanup
        --sys:service:restart mssql-server
    fi

    # sudo /usr/sbin/service mssql-server status | grep 'active' >/dev/null 2>&1
    # if [ $? != 0 ]; then
    #     --swap:install
    #     --log:cleanup
    #     sudo /usr/sbin/service mssql-server start
    # fi
}

--sys:service:ufw() {
    if [ "$(--sys:service:isactive ufw)" == "failed" ]; then
        [[ $(--sys:ufw:is_exist) -eq 1 ]] && sudo ufw enable
    fi

    # sudo ufw status | grep ' active' >/dev/null 2>&1
    # if [ $? != 0 ]; then
    #     sudo ufw enable
    # fi
}

--sys:service:vpn() {
    if [[ "$(--vpn:type)" == "client" ]]; then
        _SERVICE="openvpn@$(--host:name).service"
        if [ "$(--sys:service:isactive $_SERVICE)" == "failed" ]; then
            --vpn:init
            --sys:service:restart $_SERVICE
        fi
    fi

    if [[ "$(--vpn:type)" == "server" ]]; then
        _SERVICE="openvpn-server@server.service"
        if [ "$(--sys:service:isactive $_SERVICE)" == "failed" ]; then
            --vpn:init
            --sys:service:restart $_SERVICE
        fi
    fi

    # sudo ufw status | grep ' active' >/dev/null 2>&1
    # if [ $? != 0 ]; then
    #     sudo ufw enable
    # fi
}

--sys:service:dhcp() {
    if [ $(--host:is_server) = 1 ] && [ "$(--sys:service:isactive isc-dhcp-server)" == "failed" ]; then
        sudo killall dhcpd
        sudo rm -rf /var/run/dhcpd.pid
        --sys:service:restart isc-dhcp-server
    fi
}
#!/usr/bin/env bash
#!/bin/bash

--sys:service:cron() {
    if [ "$(--sys:service:isactive)" == "active" ]; then
        --cron:crontab:uninstall >/dev/null 2>&1
    fi

    --sys:service:httpd
    --sys:service:mysql
    --sys:service:mssql
    --sys:service:ufw
    --sys:service:vpn
}
#!/usr/bin/env bash
#!/bin/bash

--sys:service:main() {
    timer=0
    while true; do
        sleep 1
        ((timer += 1))
        timer=$(($timer % 100000))
        # // Your statements go here

        if [[ $(--sys:env:dev) -eq 1 ]]; then
            logger "Service is $(--sys:service:isactive) $timer"
        fi

        if [ $(($timer % 30)) = 0 ]; then
            --cron:cronjob:min
        fi

        if [ $(($timer % 300)) = 0 ]; then
            --cron:cronjob:5min
        fi

        if [ $(($timer % 3600)) = 0 ]; then
            --cron:cronjob:hour
        fi

        # case "$timer" in

        # 60)
        #     --cron:cronjob:min
        #     ((timer += 1))
        #     ;;

        # esac
    done

    read -t 5 -n 1 -s -r -p "Press any key to continue (5 seconds)"
}

_DUCTN_COMMANDS+=("run_as_service")
--run_as_service() {
    --sys:service:main
}

_DUCTN_COMMANDS+=("sys:service:isactive")
--sys:service:isactive() { #SERVICE_NAME
    _SERVICE_NAME=$SERVICE_NAME
    if [[ ! -z ${@+x} ]]; then
        _SERVICE_NAME="$@"
    fi
    IS_ACTIVE=$(sudo systemctl is-active $_SERVICE_NAME)
    echo $IS_ACTIVE
}

_DUCTN_COMMANDS+=("sys:service:restart")
--sys:service:restart() { #SERVICE_NAME
    _SERVICE_NAME=$SERVICE_NAME
    if [[ ! -z ${@+x} ]]; then
        _SERVICE_NAME="$@"
    fi
    if [ ! "$(--sys:service:isactive $_SERVICE_NAME)" == "inactive" ]; then
        sudo systemctl stop ${_SERVICE_NAME//'.service'/}
        sudo systemctl restart ${_SERVICE_NAME//'.service'/}
    fi
}

_DUCTN_COMMANDS+=("sys:service:re-install")
--sys:service:re-install() {
    --sys:service:unistall
    --sys:service:install
}

_DUCTN_COMMANDS+=("sys:service:install")
--sys:service:install() {
    # sudo systemctl daemon-reload
    if [ "$(--sys:service:isactive)" == "failed" ]; then
        --sys:service:unistall
    fi

    if [ "$(--sys:service:isactive)" == "inactive" ] || [ "$(--sys:service:isactive)" == "failed" ]; then
        # restart the service
        #     echo "Service is running"
        #     echo "Restarting service"
        #     sudo systemctl restart $SERVICE_NAME
        #     echo "Service restarted"
        # else

        # create service file
        # echo "Creating service file"
        echo -e "[Unit]
Description=${SERVICE_DESC//'"'/}
After=network-online.target network.target

[Service]
ExecStart=${SERVICE_PATH//'"'/}
User=ductn
WorkingDirectory=$_BASEDIR

# Kill root process
KillMode=process

# Wait up to 30 minutes for service to start/stop
TimeoutSec=1min

# Remove process, file, thread limits
#
LimitNPROC=infinity
LimitNOFILE=infinity
TasksMax=infinity
UMask=007
# Restart on non-successful exits.
Restart=on-failure

# Don't restart if we've restarted more than 10 times in 1 minute.
StartLimitInterval=60
StartLimitBurst=10

RestartSec=5s
# Type=notify
# SyslogIdentifier=Diskutilization

[Install]
WantedBy=multi-user.target
Alias=${SERVICE_NAME//'"'/}.service\n" | sudo tee /usr/lib/systemd/system/${SERVICE_NAME//'"'/}.service >/dev/null 2>&1
        # ls -la /usr/lib/systemd/system/ | grep ductn
        # ls -la /etc/systemd/system/ | grep ductn
        # restart daemon, enable and start service
        # echo "Reloading daemon and enabling service"
        sudo systemctl daemon-reload
        sudo systemctl enable ${SERVICE_NAME//'.service'/} # remove the extension
        sudo systemctl restart ${SERVICE_NAME//'.service'/}
        # sudo systemctl status ${SERVICE_NAME//'.service'/}
    # echo "Service Started"
    # echo "aaa" | sudo tee /etc/systemd/system/ductn.service
    fi
}

_DUCTN_COMMANDS+=("sys:service:uninstall")
--sys:service:unistall() {
    sudo systemctl kill ${SERVICE_NAME//'.service'/}    # remove the extension
    sudo systemctl stop ${SERVICE_NAME//'.service'/}    # remove the extension
    sudo systemctl disable ${SERVICE_NAME//'.service'/} # remove the extension
    sudo rm -rf /etc/systemd/system/*${SERVICE_NAME//'"'/}.service
    sudo rm -rf /usr/lib/systemd/system/*${SERVICE_NAME//'"'/}.service
}
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:init")
--sys:init() {
    sudo timedatectl set-timezone Asia/Ho_Chi_Minh

    sudo chown -R ductn:ductn $_BASEDIR
    chmod +x $_BASHDIR/*

    echo -e "#!/usr/bin/env bash\n#!/bin/bash\n\n. $_BASHDIR/ductn" | sudo tee /usr/local/bin/ductn >/dev/null
    sudo chown root:root /usr/local/bin/ductn
    sudo chmod +x /usr/local/bin/ductn

    --user:config $(whoami)
    rm -rf ~/.vimrc
    # ln $_BASHDIR/.vimrc ~/.vimrc
    # chmod 644 ~/.vimrc

    --sys:sysctl >/dev/null
    --ufw:iptables >/dev/null
    --git:configure

    if [ "$(whoami)" = "ductn" ]; then
        --user:config:admin
    fi

    --server() {
        --cron:install
        --httpd:config
        --ssh:install
        # ./bash/ductn --update allowip
        # else
        # sudo mkdir -p /etc/auto.master.d/
        # echo "/dxvn /etc/auto.master.d/dxvn.sshfs --timeout=30" | sudo tee /etc/auto.master.d/dxvn.autofs
        # echo "luong -fstype=nfs,rw,soft,intr,IdentityFile=/home/ductn/.ssh/id_rsa dx1.diepxuan.com:public_html" | sudo tee /etc/auto.master.d/dxvn.sshfs

        # use /etc/fstab
        # sudo mkdir -p /dxvn/luong
        # ductn@dx1.diepxuan.com:/home/ductn/public_html  /dxvn/luong  fuse.sshfs  defaults  0  0
    }

    # if [ "$(whoami)" = "ductn" ]; then
    # $_BASHDIR/ductn hosts remove 10.8.0.3 dx2
    # $_BASHDIR/ductn hosts remove 10.8.0.2 dx1
    # $_BASHDIR/ductn hosts remove 10.8.0.1 dx3
    # $_BASHDIR/ductn hosts remove 10.8.0.10 vn11
    # $_BASHDIR/ductn hosts remove 10.8.0.11 mg15
    # $_BASHDIR/ductn hosts remove 10.8.0.12 mg15kt

    # $_BASHDIR/ductn hosts remove 10.8.0.2 dx1.diepxuan.com
    # $_BASHDIR/ductn hosts remove 10.8.0.3 dx2.diepxuan.com
    # $_BASHDIR/ductn hosts remove 10.8.0.1 dx3.diepxuan.com
    # fi
    if [[ ! -z ${@+x} ]]; then
        "--$@"
    fi
}
# . $_BASHDIR/sys.sysctl
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:sysctl")
--sys:sysctl() {
    _sysctl="fs.inotify.max_user_watches=524288
net.ipv4.ip_forward=1"

    while IFS= read -r rule; do
        sudo sysctl -w $rule
    done <<<"$_sysctl"

    echo "$_sysctl" | sudo tee /etc/sysctl.d/99-ductn.conf
    sudo sysctl -p
}
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:ufw")
--sys:ufw() {
    if [ "$(--sys:ufw:is_active)" == "active" ]; then
        --sys:ufw:cleanup
        --sys:ufw:allow
        # --sys:hosts
    fi
}

_DUCTN_COMMANDS+=("sys:ufw:cleanup")
--sys:ufw:cleanup() {
    --ufw:cleanup
}

_DUCTN_COMMANDS+=("sys:ufw:allow")
--sys:ufw:allow() {
    # for domain in "${DDNS_DOMAINS[@]}"; do
    for domain in $(--sys:env:domains); do
        # echo $domain
        --sys:ufw:_allow $domain
    done
}

_DUCTN_COMMANDS+=("sys:ufw:is_active")
--sys:ufw:is_active() {
    if [ "$(--sys:service:isactive ufw)" == "active" ]; then
        echo active
    else
        if [[ $(--sys:ufw:is_exist) -eq 1 ]]; then
            sudo ufw status | grep 'inactive' >/dev/null 2>&1
            [ $? = 0 ] && echo inactive || echo active
        else
            echo inactive
        fi
    fi

    # sudo ufw status | grep 'active' >/dev/null 2>&1
    # if [ $? = 0 ]; then
    #     echo active
    # else
    #     echo deactive
    # fi
}

--sys:hosts() {
    # --hosts:add $(--host:address dxvnmg15.diepxuan.com) mg15
    # --hosts:add $(--host:address dx3.diepxuan.com) dx3

    --do_no_thing
}

--sys:ufw:_allow() {
    # sudo ufw allow proto tcp from "$(--host:address $@)" to any port 1433
    _IP=$(--host:address $@)
    if [ ! "$_IP" = "127.0.0.1" ] && [ $(--sys:ufw:is_exist $_IP) = 0 ]; then
        sudo ufw allow from "$(--host:address $@)"
    fi
}

--sys:ufw:is_exist() {
    [ ! -x "$(command -v ufw)" ] && echo 0 || echo 1
}
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("sys:vm:enable")
--sys:vm:enable() {
    sudo apt install qemu-guest-agent -y --purge --auto-remove
    sudo systemctl enable qemu-guest-agent
    sudo systemctl restart qemu-guest-agent
}

_DUCTN_COMMANDS+=("sys:vm:new")
--sys:vm:new() {
    --ssh:copy $1@$2
    ssh $1@$2 "sudo mkdir -p $_BASEDIR"
    ssh $1@$2 "sudo chown -R ductn:ductn $_BASEDIR"
    ssh $1@$2 "git archive --remote=git@bitbucket.org:DXVN/code.git master | tar -x -C $_BASEDIR"
    ssh $1@$2 "$_BASHDIR/ductn user:new ductn"
    ssh $1@$2 "$_BASHDIR/ductn sys:init"
}
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("ufw:fail2ban:install")
--ufw:fail2ban:install() {
    sudo apt install fail2ban -y --purge --auto-remove
}

_DUCTN_COMMANDS+=("ufw:fail2ban:configuration")
--ufw:fail2ban:configuration() {

    ##########################
    # mysql
    ##########################
    echo $conf_jail_mysql | sudo tee /etc/fail2ban/jail.d/mysql.conf

    echo $conf_filter_mysql_auth | sudo tee /etc/fail2ban/filter.d/mysql-auth.conf

    ##########################
    # sshd invaliduser
    ##########################
    echo $conf_jail_sshd_invaliduser | sudo tee /etc/fail2ban/jail.d/sshd-invaliduser.conf

    echo $conf_filter_sshd_invaliduser | sudo tee /etc/fail2ban/filter.d/sshd-invaliduser.conf

    ##########################
    # mssqld invaliduser
    ##########################
    # echo $conf_jail_mssql_server | sudo tee /etc/fail2ban/jail.d/mssql-server.conf

    # echo $conf_filter_mssql_server | sudo tee /etc/fail2ban/filter.d/mssql-server.conf

    sudo service fail2ban restart
}

conf_jail_mysql="# To log wrong MySQL access attempts add to /etc/my.cnf in [mysqld] or
# equivalent section:
# log-warnings = 2
#
# for syslog (daemon facility)
# [mysqld_safe]
# syslog
#
# for own logfile
# [mysqld]
# log-error=/var/log/mysqld.log
[mysql-auth]
enabled  = true
maxretry = 3
port     = 3306
logpath  = /var/log/syslog
backend  = %(mysql_backend)s"

conf_filter_mysql_auth="# Fail2Ban filter for unsuccesful MySQL authentication attempts
#
#
# To log wrong MySQL access attempts add to /etc/my.cnf in [mysqld]:
# log-error=/var/log/mysqld.log
# log-warnings = 2
#
# If using mysql syslog [mysql_safe] has syslog in /etc/my.cnf

[INCLUDES]

# Read common prefixes. If any customizations available -- read them from
# common.local
before = common.conf

[Definition]

_daemon = mysql

failregex = ^%(__prefix_line)s(?:(?:\d{6}|\d{4}-\d{2}-\d{2})[ T]\s?\d{1,2}:\d{2}:\d{2} )?(?:\d+ )?\[\w+\] (?:\[[^\]]+\] )*Access denied for user '[^']+'@'<HOST>' (to database '[^']*'|\(using password: (YES|NO)\))*\s*$

ignoreregex =

# DEV Notes:
#
# Technically __prefix_line can equate to an empty string hence it can support
# syslog and non-syslog at once.
# Example:
# 130322 11:26:54 [Warning] Access denied for user 'root'@'127.0.0.1' (using password: YES)
#
# Authors: Artur Penttinen
#          Yaroslav O. Halchenko"

conf_jail_sshd_invaliduser="[sshd-invaliduser]
enabled = true
maxretry = 1
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s"

conf_filter_sshd_invaliduser="[INCLUDES]
before = common.conf

[Definition]
_daemon = sshd

failregex = ^%(__prefix_line)s[iI](?:llegal|nvalid) user .*? from <HOST>(?: port \d+)?\s*$
ignoreregex =

[Init]
journalmatch = _SYSTEMD_UNIT=sshd.service + _COMM=sshd"

conf_jail_mssql_server="[mssql-server]
enabled = true
port    = 1433
logpath = /var/opt/mssql/log/errorlog
backend = %(default_backend)s"

conf_filter_mssql_server="# Fail2Ban filter for unsuccesfull MSSQL authentication attempts

[INCLUDES]

# Read common prefixes. If any customizations available -- read them from
# common.local
before = common.conf

[Definition]

_daemon = mssql-server

failregex = ^%(__prefix_line)s.*Login failed for user '[A-Za-z ]*'. Reason: .*provided. \[CLIENT: <HOST>\]

#failregex = ^%(__prefix_line)s.*Login failed for user '[A-Za-z ]*'. Reason: Password did not match that for the login provided. \[CLIENT: <HOST>
#Login failed for user 'sa'. Reason: Password did not match that for the login provided. [CLIENT: <HOST>]*\s*$

ignoreregex ="
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("ufw:geoip:install")
--ufw:geoip:install() {
    sudo apt install curl unzip perl -y --purge --auto-remove
    sudo apt install xtables-addons-common -y --purge --auto-remove
    sudo apt install libtext-csv-xs-perl libmoosex-types-netaddr-ip-perl -y --purge --auto-remove
}

_DUCTN_COMMANDS+=("ufw:geoip:update")
--ufw:geoip:update() {
    MON=$(date +"%m")
    YR=$(date +"%Y")
    sudo mkdir -p /usr/share/xt_geoip
    sudo chmod +x /usr/lib/xtables-addons/*

    sudo rm /usr/share/xt_geoip/dbip-country-lite.csv
    (cd /usr/share/xt_geoip && sudo /usr/lib/xtables-addons/xt_geoip_dl)

    # sudo wget https://download.db-ip.com/free/dbip-country-lite-${YR}-${MON}.csv.gz -O /usr/share/xt_geoip/dbip-country-lite.csv.gz
    # sudo gunzip /usr/share/xt_geoip/dbip-country-lite.csv.gz

    sudo /usr/lib/xtables-addons/xt_geoip_build -D /usr/share/xt_geoip/ -S /usr/share/xt_geoip/
    sudo rm /usr/share/xt_geoip/dbip-country-lite.csv
}

_DUCTN_COMMANDS+=("ufw:geoip:configuration")
--ufw:geoip:configuration() {
    --ufw:geoip:update
    sudo modprobe xt_geoip
    # lsmod | grep ^xt_geoip
    # iptables -m geoip -h

    ##########################
    # /etc/ufw/before.rules  #
    # /etc/ufw/before6.rules #
    ##########################
    # GeoIp
    # -A ufw-before-input -m geoip ! --src-cc VN -j LOG --log-prefix "[BLOCKED COUNTRIES] "
    # -A ufw-before-input -m geoip ! --src-cc VN -j DROP
}

_DUCTN_COMMANDS+=("ufw:geoip:allowCloudflare")
--ufw:geoip:allowCloudflare() {
    # Allow Cloudflare IP
    # https://www.cloudflare.com/ips-v4
    # https://www.cloudflare.com/ips-v6
    # iptables -I INPUT -p tcp -m multiport --dports http,https -s $ip -j ACCEPT
    # -A ufw-before-input -p tcp -m multiport --dports http,https -s $ip -j ACCEPT

    v4ips="https://www.cloudflare.com/ips-v4"
    # echo "# v4: add to file /etc/ufw/before.rules"
    # echo "########################################"
    while IFS= read -r line; do
        echo -e "-A ufw-before-input -p tcp -m multiport --dports http,https -s ${line} -j ACCEPT\n"
    done < <(curl -s $v4ips)

    echo -e "\n\n"

    v6ips="https://www.cloudflare.com/ips-v6"
    # echo "# v6: add to file /etc/ufw/before6.rules"
    # echo "########################################"
    while IFS= read -r line; do
        echo -e "-A ufw-before-input -p tcp -m multiport --dports http,https -s ${line} -j ACCEPT\n"
    done < <(curl -s $v6ips)
}
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("ufw:iptables")
--ufw:iptables() {
    iptables_path=$(--ufw:iptables:path4)
    ip6tables_path=$(--ufw:iptables:path6)
    iptables_rules_HEAD=""
    iptables_rules_FOOT=""

    _SRV_NUM=$(--host:name)
    _SRV_NUM=${_SRV_NUM:3}

    function _rule_out() {
        # echo -e "$@"
        while IFS= read -r _rule; do
            _rule=${_rule//'.pve.'/".$_SRV_NUM."}

            # [[ -n $_rule ]] && echo -e "ExecStart=$iptables_path\t$_rule" | sudo tee -a /usr/lib/systemd/system/ductn-iptables.service
            [[ -n $_rule ]] && iptables_rules_HEAD="$iptables_rules_HEAD\nExecStart=$iptables_path $_rule"

            _rule=${_rule//'-A '/'-D '}
            _rule=${_rule//'-I '/'-D '}
            _rule=${_rule//'-N '/'-X '}

            # [[ -n $_rule ]] && echo -e "ExecStop=$iptables_path\t$_rule" | sudo tee -a /usr/lib/systemd/system/ductn-iptables.service
            [[ -n $_rule ]] && iptables_rules_FOOT="ExecStop=$iptables_path $_rule\n$iptables_rules_FOOT"
        done <<<"$@"
    }

    function _rule_nat() {
        _ip=$1
        _port=$2
        [[ -z "$_port" ]] && _port="80"
        [[ ! -z $_ip ]] && _rule_out "-t nat -A PREROUTING -p TCP --dport $_port -j DNAT --to-destination $_ip"
    }

    ######### UFW allow Cloudflare ips #########
    _chain_exists() {
        [ $# -lt 1 -o $# -gt 2 ] && {
            echo "Usage: chain_exists <chain_name> [table]" >&2
            return 1
        }
        local chain_name="$1"
        shift
        [ $# -eq 1 ] && local table="--table $1"
        sudo ${iptables_path} $table -n --list "$chain_name" >/dev/null 2>&1
    }

    if $(_chain_exists ufw-before-input); then
        while IFS= read -r rule; do
            _rule_out $rule
        done < <(--ufw:geoip:allowCloudflare)
    fi

    ######### VPN Firewall Site-to-Site #########
    if [[ $(--host:is_server) == 1 ]]; then
        # Allow internet access for vm clients
        _rule_out "-t nat -A POSTROUTING -s '10.0.pve.0/24' -o vmbr0 -j MASQUERADE"
        _rule_out "-t raw -I PREROUTING -i fwbr+ -j CT --zone 1"
        [[ "$(ip tuntap show | grep tun0)" != "" ]] && _rule_out "-t nat -A POSTROUTING -s '10.0.pve.0/24' -o tun0 -j MASQUERADE"

        # NAT port to vm client
        for nat in $(--sys:env nat); do
            # IFS=':' read -r -a array <<<$nat
            # port="${array[0]}"
            # address="${array[1]}"

            # port=$(echo $nat | cut -d':' -f 1)
            # address=$(echo $nat | cut -d':' -f 2)

            port=${nat%:*}    # remove suffix starting with "_"
            address=${nat#*:} # remove prefix ending in "_"

            [[ -n $port ]] && [[ -n $address ]] && _rule_out "-t nat -A PREROUTING -p TCP --dport $port -j DNAT --to-destination $address"
        done
    fi

    ######### VPN Firewall DMZ to Pve server #########
    if [[ $(--host:is_vpn_server) == 1 ]]; then
        # load modules
        sudo /sbin/depmod -a
        sudo /sbin/modprobe ip_tables
        sudo /sbin/modprobe ip_conntrack
        sudo /sbin/modprobe iptable_filter
        sudo /sbin/modprobe iptable_mangle
        sudo /sbin/modprobe iptable_nat
        sudo /sbin/modprobe ipt_LOG
        sudo /sbin/modprobe ipt_limit
        sudo /sbin/modprobe ipt_state
        sudo /sbin/modprobe ipt_MASQUERADE

        _rule_out "$(--ufw:dmz)"
    fi

    echo -e "[Unit]
Description=Ductn iptables service
Before=network.target

[Service]
Type=oneshot
$iptables_rules_HEAD

$iptables_rules_FOOT
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target" | sudo tee /usr/lib/systemd/system/ductn-iptables.service

    # sudo  systemctl enable --now ductn-iptables.service
    # cat /usr/lib/systemd/system/ductn-iptables.service

    sudo systemctl daemon-reload
    sudo systemctl enable ductn-iptables
    sudo systemctl stop ductn-iptables
    sudo $iptables_path -X bad_tcp_packets 2>/dev/null
    sudo $iptables_path -X allowed 2>/dev/null
    sudo $iptables_path -X icmp_packets 2>/dev/null

    sudo systemctl restart ductn-iptables

    if [ "$(--sys:service:isactive ductn-iptables)" == "failed" ]; then
        sudo systemctl status ductn-iptables
    fi
}

--ufw:iptables:path4() {
    # Create a service to set up persistent iptables rules
    iptables_path=$(sudo su -c "command -v iptables")
    # nf_tables is not available as standard in OVZ kernels. So use iptables-legacy
    # if we are in OVZ, with a nf_tables backend and iptables-legacy is available.
    if [[ $(systemd-detect-virt) == "openvz" ]] && readlink -f "$(sudo su -c "command -v iptables")" | grep -q "nft" && hash iptables-legacy 2>/dev/null; then
        iptables_path=$(sudo su -c "command -v iptables-legacy")
    fi
    echo "$iptables_path"
}

--ufw:iptables:path6() {
    ip6tables_path=$(sudo su -c "command -v ip6tables")
    if [[ $(systemd-detect-virt) == "openvz" ]] && readlink -f "$(sudo su -c "command -v iptables")" | grep -q "nft" && hash iptables-legacy 2>/dev/null; then
        ip6tables_path=$(sudo su -c "command -v ip6tables-legacy")
    fi
    echo $ip6tables_path
}

--ufw:dmz() {
    DMZ_RULES=""

    INET_IP="$(--ip:wan)"
    INET_IFACE="$(route | grep '^default' | grep -o '[^ ]*$')"

    LAN_IP="$(--ip:local)"
    # LAN_IFACE="tun0"

    DMZ_IP="10.8.0.2"
    DMZ_IFACE="tun0"

    LO_IFACE="lo"
    LO_IP="127.0.0.1"

    # echo "-X bad_tcp_packets"
    echo "-N bad_tcp_packets"
    echo "-N allowed"
    echo "-N icmp_packets"

    echo "-A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j LOG --log-prefix \"New not syn:\""
    echo "-A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j DROP"

    echo "-A bad_tcp_packets -i $INET_IFACE -s 192.168.0.0/16 -j DROP"
    echo "-A bad_tcp_packets -i $INET_IFACE -s 10.0.0.0/8 -j DROP"
    echo "-A bad_tcp_packets -i $INET_IFACE -s 172.16.0.0/12 -j DROP"
    echo "-A bad_tcp_packets -i $INET_IFACE -s $INET_IP -j DROP"

    echo "-A allowed -p TCP --syn -j ACCEPT"
    echo "-A allowed -p TCP -m state --state ESTABLISHED,RELATED -j ACCEPT"
    echo "-A allowed -p TCP -j DROP"

    echo "-A icmp_packets -p ICMP -s 0/0 --icmp-type 0 -j ACCEPT"
    echo "-A icmp_packets -p ICMP -s 0/0 --icmp-type 3 -j ACCEPT"
    echo "-A icmp_packets -p ICMP -s 0/0 --icmp-type 5 -j ACCEPT"
    echo "-A icmp_packets -p ICMP -s 0/0 --icmp-type 8 -j ACCEPT"
    echo "-A icmp_packets -p ICMP -s 0/0 --icmp-type 11 -j ACCEPT"

    echo "-A INPUT -p tcp -j bad_tcp_packets"
    echo "-A INPUT -p ICMP -i $INET_IFACE -j icmp_packets"
    echo "-A INPUT -p ALL -i $DMZ_IFACE -d $DMZ_IP -j ACCEPT"
    # echo "-A INPUT -p ALL -i $LAN_IFACE -d $LAN_IP -j ACCEPT"
    # echo "-A INPUT -p ALL -i $LAN_IFACE -d $LAN_BROADCAST_ADDRESS -j ACCEPT"
    echo "-A INPUT -p ALL -i $LO_IFACE -s $LO_IP -j ACCEPT"
    echo "-A INPUT -p ALL -i $LO_IFACE -s $LAN_IP -j ACCEPT"
    echo "-A INPUT -p ALL -i $LO_IFACE -s $INET_IP -j ACCEPT"
    echo "-A INPUT -p ALL -d $INET_IP -m state --state ESTABLISHED,RELATED -j ACCEPT"
    echo "-A INPUT -m limit --limit 3/minute --limit-burst 3 -j LOG --log-prefix \"IPT INPUT packet died: \""

    echo "-A FORWARD -p tcp -j bad_tcp_packets"
    echo "-A FORWARD -i $DMZ_IFACE -o $INET_IFACE -j ACCEPT"
    echo "-A FORWARD -i $INET_IFACE -o $DMZ_IFACE -m state --state ESTABLISHED,RELATED -j ACCEPT"
    # echo "-A FORWARD -i $LAN_IFACE -o $DMZ_IFACE -j ACCEPT"
    # echo "-A FORWARD -i $DMZ_IFACE -o $LAN_IFACE -m state --state ESTABLISHED,RELATED -j ACCEPT"
    echo "-A FORWARD -m limit --limit 3/minute --limit-burst 3 -j LOG --log-prefix \"IPT FORWARD packet died: \""

    echo "-A OUTPUT -p tcp -j bad_tcp_packets"
    echo "-A OUTPUT -m limit --limit 3/minute --limit-burst 3 -j LOG --log-prefix \"IPT OUTPUT packet died: \""

    echo "-t nat -A POSTROUTING -o $INET_IFACE -j SNAT --to-source $INET_IP"
    echo "-t nat -A PREROUTING -p TCP -i $INET_IFACE -d $INET_IP --dport 53 -j DNAT --to-destination $DMZ_IP"
    echo "-t nat -A PREROUTING -p UDP -i $INET_IFACE -d $INET_IP --dport 53 -j DNAT --to-destination $DMZ_IP"

    # NAT port to vm client
    for nat in $(--sys:env nat); do
        port=${nat%:*} # remove suffix starting with "_"
        [[ -n $port ]] && echo "-t nat -A PREROUTING -p TCP -i $INET_IFACE -d $INET_IP --dport $port -j DNAT --to-destination $DMZ_IP"
    done

    # echo "-t nat -A PREROUTING -i $INET_IFACE -s 192.168.0.0/16 -j DROP"
    # echo "-t nat -A PREROUTING -i $INET_IFACE -s 10.0.0.0/8 -j DROP"
    # echo "-t nat -A PREROUTING -i $INET_IFACE -s 172.16.0.0/12 -j DROP"
    # echo "-t nat -A PREROUTING -i $INET_IFACE -s $INET_IP -j DROP"
}

--ufw:DMZ_example() {
    #!/bin/sh
    #
    # rc.DMZ.firewall - DMZ IP Firewall script for Linux 2.4.x and iptables
    #
    # Copyright (C) 2001  Oskar Andreasson <bluefluxATkoffeinDOTnet>
    #
    # This program is free software; you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation; version 2 of the License.
    #
    # This program is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.
    #
    # You should have received a copy of the GNU General Public License
    # along with this program or from the site that you downloaded it
    # from; if not, write to the Free Software Foundation, Inc., 59 Temple
    # Place, Suite 330, Boston, MA  02111-1307   USA
    #

    ###########################################################################
    #
    # 1. Configuration options.
    #

    #
    # 1.1 Internet Configuration.
    #

    INET_IP="194.236.50.152"
    HTTP_IP="194.236.50.153"
    DNS_IP="194.236.50.154"
    INET_IFACE="eth0"

    #
    # 1.1.1 DHCP
    #

    #
    # 1.1.2 PPPoE
    #

    #
    # 1.2 Local Area Network configuration.
    #
    # your LAN's IP range and localhost IP. /24 means to only use the first 24
    # bits of the 32 bit IP address. the same as netmask 255.255.255.0
    #

    LAN_IP="192.168.0.2"
    LAN_IFACE="eth1"

    #
    # 1.3 DMZ Configuration.
    #

    DMZ_HTTP_IP="192.168.1.2"
    DMZ_DNS_IP="192.168.1.3"
    DMZ_IP="192.168.1.1"
    DMZ_IFACE="eth2"

    #
    # 1.4 Localhost Configuration.
    #

    LO_IFACE="lo"
    LO_IP="127.0.0.1"

    #
    # 1.5 IPTables Configuration.
    #

    IPTABLES="/usr/sbin/iptables"

    #
    # 1.6 Other Configuration.
    #

    ###########################################################################
    #
    # 2. Module loading.
    #

    #
    # Needed to initially load modules
    #
    /sbin/depmod -a

    #
    # 2.1 Required modules
    #

    /sbin/modprobe ip_tables
    /sbin/modprobe ip_conntrack
    /sbin/modprobe iptable_filter
    /sbin/modprobe iptable_mangle
    /sbin/modprobe iptable_nat
    /sbin/modprobe ipt_LOG
    /sbin/modprobe ipt_limit
    /sbin/modprobe ipt_state

    #
    # 2.2 Non-Required modules
    #

    #/sbin/modprobe ipt_owner
    #/sbin/modprobe ipt_REJECT
    #/sbin/modprobe ipt_MASQUERADE
    #/sbin/modprobe ip_conntrack_ftp
    #/sbin/modprobe ip_conntrack_irc
    #/sbin/modprobe ip_nat_ftp
    #/sbin/modprobe ip_nat_irc

    ###########################################################################
    #
    # 3. /proc set up.
    #

    #
    # 3.1 Required proc configuration
    #

    echo "1" >/proc/sys/net/ipv4/ip_forward

    #
    # 3.2 Non-Required proc configuration
    #

    #echo "1" > /proc/sys/net/ipv4/conf/all/rp_filter
    #echo "1" > /proc/sys/net/ipv4/conf/all/proxy_arp
    #echo "1" > /proc/sys/net/ipv4/ip_dynaddr

    ###########################################################################
    #
    # 4. rules set up.
    #

    ######
    # 4.1 Filter table
    #

    #
    # 4.1.1 Set policies
    #

    $IPTABLES -P INPUT DROP
    $IPTABLES -P OUTPUT DROP
    $IPTABLES -P FORWARD DROP

    #
    # 4.1.2 Create userspecified chains
    #

    #
    # Create chain for bad tcp packets
    #

    $IPTABLES -N bad_tcp_packets

    #
    # Create separate chains for ICMP, TCP and UDP to traverse
    #

    $IPTABLES -N allowed
    $IPTABLES -N icmp_packets

    #
    # 4.1.3 Create content in userspecified chains
    #

    #
    # bad_tcp_packets chain
    #

    $IPTABLES -A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j LOG \
        --log-prefix "New not syn:"
    $IPTABLES -A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j DROP

    #
    # allowed chain
    #

    $IPTABLES -A allowed -p TCP --syn -j ACCEPT
    $IPTABLES -A allowed -p TCP -m state --state ESTABLISHED,RELATED -j ACCEPT
    $IPTABLES -A allowed -p TCP -j DROP

    #
    # ICMP rules
    #

    # Changed rules totally
    $IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 8 -j ACCEPT
    $IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 11 -j ACCEPT

    #
    # 4.1.4 INPUT chain
    #

    #
    # Bad TCP packets we don't want
    #

    $IPTABLES -A INPUT -p tcp -j bad_tcp_packets

    #
    # Packets from the Internet to this box
    #

    $IPTABLES -A INPUT -p ICMP -i $INET_IFACE -j icmp_packets

    #
    # Packets from LAN, DMZ or LOCALHOST
    #

    #
    # From DMZ Interface to DMZ firewall IP
    #

    $IPTABLES -A INPUT -p ALL -i $DMZ_IFACE -d $DMZ_IP -j ACCEPT

    #
    # From LAN Interface to LAN firewall IP
    #

    $IPTABLES -A INPUT -p ALL -i $LAN_IFACE -d $LAN_IP -j ACCEPT
    $IPTABLES -A INPUT -p ALL -i $LAN_IFACE -d $LAN_BROADCAST_ADDRESS -j ACCEPT

    #
    # From Localhost interface to Localhost IP's
    #

    $IPTABLES -A INPUT -p ALL -i $LO_IFACE -s $LO_IP -j ACCEPT
    $IPTABLES -A INPUT -p ALL -i $LO_IFACE -s $LAN_IP -j ACCEPT
    $IPTABLES -A INPUT -p ALL -i $LO_IFACE -s $INET_IP -j ACCEPT

    #
    # Special rule for DHCP requests from LAN, which are not caught properly
    # otherwise.
    #

    $IPTABLES -A INPUT -p UDP -i $LAN_IFACE --dport 67 --sport 68 -j ACCEPT

    #
    # All established and related packets incoming from the internet to the
    # firewall
    #

    $IPTABLES -A INPUT -p ALL -d $INET_IP -m state --state ESTABLISHED,RELATED \
        -j ACCEPT

    #
    # In Microsoft Networks you will be swamped by broadcasts. These lines
    # will prevent them from showing up in the logs.
    #

    #$IPTABLES -A INPUT -p UDP -i $INET_IFACE -d $INET_BROADCAST \
    #--destination-port 135:139 -j DROP

    #
    # If we get DHCP requests from the Outside of our network, our logs will
    # be swamped as well. This rule will block them from getting logged.
    #

    #$IPTABLES -A INPUT -p UDP -i $INET_IFACE -d 255.255.255.255 \
    #--destination-port 67:68 -j DROP

    #
    # If you have a Microsoft Network on the outside of your firewall, you may
    # also get flooded by Multicasts. We drop them so we do not get flooded by
    # logs
    #

    #$IPTABLES -A INPUT -i $INET_IFACE -d 224.0.0.0/8 -j DROP

    #
    # Log weird packets that don't match the above.
    #

    $IPTABLES -A INPUT -m limit --limit 3/minute --limit-burst 3 -j LOG \
        --log-level DEBUG --log-prefix "IPT INPUT packet died: "

    #
    # 4.1.5 FORWARD chain
    #

    #
    # Bad TCP packets we don't want
    #

    $IPTABLES -A FORWARD -p tcp -j bad_tcp_packets

    #
    # DMZ section
    #
    # General rules
    #

    $IPTABLES -A FORWARD -i $DMZ_IFACE -o $INET_IFACE -j ACCEPT
    $IPTABLES -A FORWARD -i $INET_IFACE -o $DMZ_IFACE -m state \
        --state ESTABLISHED,RELATED -j ACCEPT
    $IPTABLES -A FORWARD -i $LAN_IFACE -o $DMZ_IFACE -j ACCEPT
    $IPTABLES -A FORWARD -i $DMZ_IFACE -o $LAN_IFACE -m state \
        --state ESTABLISHED,RELATED -j ACCEPT

    #
    # HTTP server
    #

    $IPTABLES -A FORWARD -p TCP -i $INET_IFACE -o $DMZ_IFACE -d $DMZ_HTTP_IP \
        --dport 80 -j allowed
    $IPTABLES -A FORWARD -p ICMP -i $INET_IFACE -o $DMZ_IFACE -d $DMZ_HTTP_IP \
        -j icmp_packets

    #
    # DNS server
    #

    $IPTABLES -A FORWARD -p TCP -i $INET_IFACE -o $DMZ_IFACE -d $DMZ_DNS_IP \
        --dport 53 -j allowed
    $IPTABLES -A FORWARD -p UDP -i $INET_IFACE -o $DMZ_IFACE -d $DMZ_DNS_IP \
        --dport 53 -j ACCEPT
    $IPTABLES -A FORWARD -p ICMP -i $INET_IFACE -o $DMZ_IFACE -d $DMZ_DNS_IP \
        -j icmp_packets

    #
    # LAN section
    #

    $IPTABLES -A FORWARD -i $LAN_IFACE -j ACCEPT
    $IPTABLES -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

    #
    # Log weird packets that don't match the above.
    #

    $IPTABLES -A FORWARD -m limit --limit 3/minute --limit-burst 3 -j LOG \
        --log-level DEBUG --log-prefix "IPT FORWARD packet died: "

    #
    # 4.1.6 OUTPUT chain
    #

    #
    # Bad TCP packets we don't want.
    #

    $IPTABLES -A OUTPUT -p tcp -j bad_tcp_packets

    #
    # Special OUTPUT rules to decide which IP's to allow.
    #

    $IPTABLES -A OUTPUT -p ALL -s $LO_IP -j ACCEPT
    $IPTABLES -A OUTPUT -p ALL -s $LAN_IP -j ACCEPT
    $IPTABLES -A OUTPUT -p ALL -s $INET_IP -j ACCEPT

    #
    # Log weird packets that don't match the above.
    #

    $IPTABLES -A OUTPUT -m limit --limit 3/minute --limit-burst 3 -j LOG \
        --log-level DEBUG --log-prefix "IPT OUTPUT packet died: "

    ######
    # 4.2 nat table
    #

    #
    # 4.2.1 Set policies
    #

    #
    # 4.2.2 Create user specified chains
    #

    #
    # 4.2.3 Create content in user specified chains
    #

    #
    # 4.2.4 PREROUTING chain
    #

    $IPTABLES -t nat -A PREROUTING -p TCP -i $INET_IFACE -d $HTTP_IP --dport 80 \
        -j DNAT --to-destination $DMZ_HTTP_IP
    $IPTABLES -t nat -A PREROUTING -p TCP -i $INET_IFACE -d $DNS_IP --dport 53 \
        -j DNAT --to-destination $DMZ_DNS_IP
    $IPTABLES -t nat -A PREROUTING -p UDP -i $INET_IFACE -d $DNS_IP --dport 53 \
        -j DNAT --to-destination $DMZ_DNS_IP

    #
    # 4.2.5 POSTROUTING chain
    #

    #
    # Enable simple IP Forwarding and Network Address Translation
    #

    $IPTABLES -t nat -A POSTROUTING -o $INET_IFACE -j SNAT --to-source $INET_IP

    #
    # 4.2.6 OUTPUT chain
    #

    ######
    # 4.3 mangle table
    #

    #
    # 4.3.1 Set policies
    #

    #
    # 4.3.2 Create user specified chains
    #

    #
    # 4.3.3 Create content in user specified chains
    #

    #
    # 4.3.4 PREROUTING chain
    #

    #
    # 4.3.5 INPUT chain
    #

    #
    # 4.3.6 FORWARD chain
    #

    #
    # 4.3.7 OUTPUT chain
    #

    #
    # 4.3.8 POSTROUTING chain
    #
}

--ufw:DMZ_example2() {
    #!/bin/sh
    #
    # rc.DMZ.firewall - DMZ IP Firewall script for Linux 2.4.x
    #
    # Author: Oskar Andreasson <blueflux@koffein.net>
    # (c) of BoingWorld.com, use at your own risk, do whatever you please with
    # it as long as you don't distribute this without due credits to
    # BoingWorld.com
    #

    ###########
    # Configuration options, these will speed you up getting this script to
    # work with your own setup.

    #
    # your LAN's IP range and localhost IP. /24 means to only use the first 24
    # bits of the 32 bit IP adress. the same as netmask 255.255.255.0
    #
    # STATIC_IP is used by me to allow myself to do anything to myself, might
    # be a security risc but sometimes I want this. If you don't have a static
    # IP, I suggest not using this option at all for now but it's stil
    # enabled per default and will add some really nifty security bugs for all
    # those who skips reading the documentation=)

    LAN_IP="192.168.0.2"
    LAN_BCAST_ADRESS="192.168.0.255"
    LAN_IFACE="eth1"

    INET_IP="194.236.50.152"
    INET_IFACE="eth0"

    HTTP_IP="194.236.50.153"
    DNS_IP="194.236.50.154"
    DMZ_HTTP_IP="192.168.1.2"
    DMZ_DNS_IP="192.168.1.3"
    DMZ_IP="192.168.1.1"
    DMZ_IFACE="eth2"

    LO_IP="127.0.0.1"
    LO_IFACE="lo"

    IPTABLES="/usr/local/sbin/iptables"

    ###########################################
    #
    # Load all required IPTables modules unless compiled into the kernel
    #

    #
    # Needed to initially load modules
    #

    /sbin/depmod -a

    #
    # Adds some iptables targets like LOG, REJECT and MASQUARADE.
    #

    /sbin/modprobe ipt_LOG
    /sbin/modprobe ipt_MASQUERADE

    #
    # Support for connection tracking of FTP and IRC.
    #
    #/sbin/modprobe ip_conntrack_ftp
    #/sbin/modprobe ip_conntrack_irc

    #CRITICAL:  Enable IP forwarding since it is disabled by default.
    #

    echo "1" >/proc/sys/net/ipv4/ip_forward

    #
    # Dynamic IP users:
    #
    #echo "1" > /proc/sys/net/ipv4/ip_dynaddr

    ###########################################
    #
    # Chain Policies gets set up before any bad packets gets through
    #

    $IPTABLES -P INPUT DROP
    $IPTABLES -P OUTPUT DROP
    $IPTABLES -P FORWARD DROP

    #
    # the allowed chain for TCP connections, utilized in the FORWARD chain
    #

    $IPTABLES -N allowed
    $IPTABLES -A allowed -p TCP --syn -j ACCEPT
    $IPTABLES -A allowed -p TCP -m state --state ESTABLISHED,RELATED -j ACCEPT
    $IPTABLES -A allowed -p TCP -j DROP

    #
    # ICMP rules, utilized in the FORWARD chain
    #

    $IPTABLES -N icmp_packets
    $IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 0 -j ACCEPT
    $IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 3 -j ACCEPT
    $IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 5 -j ACCEPT
    $IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 11 -j ACCEPT

    ###########################################
    # POSTROUTING chain in the nat table
    #
    # Enable IP SNAT for all internal networks trying to get out on the Internet
    #

    $IPTABLES -t nat -A POSTROUTING -o $INET_IFACE -j SNAT --to-source $INET_IP

    ###########################################
    # PREROUTING chain in the nat table
    #
    # Do some checks for obviously spoofed IP's
    #

    $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -s 192.168.0.0/16 -j DROP
    $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -s 10.0.0.0/8 -j DROP
    $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -s 172.16.0.0/12 -j DROP
    $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -s $INET_IP -j DROP

    #
    # Enable IP Destination NAT for DMZ zone
    #

    $IPTABLES -t nat -A PREROUTING -p TCP -i $INET_IFACE -d $HTTP_IP --dport 80 \
        -j DNAT --to-destination $DMZ_HTTP_IP
    $IPTABLES -t nat -A PREROUTING -p TCP -i $INET_IFACE -d $DNS_IP --dport 53 \
        -j DNAT --to-destination $DMZ_DNS_IP
    $IPTABLES -t nat -A PREROUTING -p UDP -i $INET_IFACE -d $DNS_IP --dport 53 \
        -j DNAT --to-destination $DMZ_DNS_IP

    ###########################################
    #
    # FORWARD chain
    #
    # Get rid of bad TCP packets
    #

    $IPTABLES -A FORWARD -p tcp ! --syn -m state --state NEW -j LOG \
        --log-prefix "New not syn:"
    $IPTABLES -A FORWARD -p tcp ! --syn -m state --state NEW -j DROP

    #
    # DMZ section
    #
    # General rules
    #

    $IPTABLES -A FORWARD -i $DMZ_IFACE -o $INET_IFACE -j ACCEPT
    $IPTABLES -A FORWARD -i $INET_IFACE -o $DMZ_IFACE -m state \
        --state ESTABLISHED,RELATED -j ACCEPT
    $IPTABLES -A FORWARD -i $LAN_IFACE -o $DMZ_IFAC

}
#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("ufw:cleanup")
--ufw:cleanup() {
    TYPE=$1

    DDNS_IPS=()
    # for domain in "${DDNS_DOMAINS[@]}"; do
    for domain in $(--sys:env:domains); do
        IP="$(--host:address $domain)"
        DDNS_IPS+=($IP)
    done

    sudo ufw status numbered | sed -n '/Anywhere[[:space:]]\+ALLOW IN[[:space:]]\+/p' | while read line; do
        line="$(echo "$line" | sed -r 's/[[:space:]*[0-9]+][[:space:]]Anywhere[[:space:]]+ALLOW IN[[:space:]]+//g')"
        line="$(echo "$line" | sed -r 's/\/tcp//g')"

        if [[ " ${DDNS_IPS[*]} " =~ " ${line} " ]]; then
            [[ $TYPE =~ "cmd" ]] && --echo "Exist $line"
        else
            # sudo ufw delete allow proto tcp from "$line"
            sudo ufw delete allow from "$line"
            [[ $TYPE =~ "cmd" ]] && --echo "Remove $line"
        fi

    done
}

_DUCTN_COMMANDS+=("ufw:profile:mssql")
--ufw:profile:mssql() {
    echo -e "$ufw_profile_mssql" | sudo tee /etc/ufw/applications.d/mssql.ufw.profile >/dev/null
}

ufw_profile_mssql="[SQLServer]
title=SQLServer
description=SQLServer server.
ports=1433/tcp|1434/udp
"
#!/usr/bin/env bash
#!/bin/bash

# options_found=0
# while getopts ":u" opt; do
#     options_found=1
#     case $opt in
#     u)
#         username=$OPTARG
#         echo "username = $OPTARG"
#         ;;
#     esac
# done

# if ((!options_found)); then
#     echo "no options found"
# fi

_SSHDIR="$_LIBDIR/ssh"

_DUCTN_COMMANDS+=("user:new")
--user:new() {
    #!/bin/bash

    sudo adduser ${1} --disabled-password --gecos \"\"
    sudo adduser ${1} www-data
    sudo usermod -aG www-data ${1}
    id -u ${1}

    --user:config ${1}
}

_DUCTN_COMMANDS+=("user:config")
--user:config() {
    if [[ ${1} = "ductn" ]]; then
        --user:config:admin

        sudo usermod -aG mssql ${1} >/dev/null 2>&1
    fi

    --user:config:bash ${1}
    --user:config:ssh ${1}
    --user:config:chmod ${1}
}

--user:config:bash() {
    sudo sed -i 's/.*force_color_prompt\=.*/force_color_prompt\=yes/' /home/${1}/.bashrc >/dev/null

    sudo touch /home/${1}/.bash_aliases
    echo -e "#!/usr/bin/env bash\n#!/bin/bash\n\n. $_BASHDIR/.bash_aliases" | sudo tee /home/${1}/.bash_aliases >/dev/null

    sudo chmod 644 /home/${1}/.bash_aliases
    sudo chown -R ${1}:${1} /home/${1}/.bash_aliases

    [ "$(whoami)" = "$1" ] && source /home/${1}/.bashrc
}

--user:config:ssh() {
    sudo mkdir -p /home/${1}/.ssh

    cat $_SSHDIR/id_rsa | sudo tee /home/${1}/.ssh/id_rsa >/dev/null
    cat $_SSHDIR/id_rsa.pub | sudo tee /home/${1}/.ssh/id_rsa.pub >/dev/null
    cat $_SSHDIR/id_rsa.pub | sudo tee --append /home/${1}/.ssh/authorized_keys >/dev/null

    sudo chown -R ${1}:${1} /home/${1}/.ssh
}

--user:config:chmod() {
    sudo chmod 755 /home/${1}

    sudo mkdir -p /home/${1}/.ssh
    sudo chmod 777 /home/${1}/.ssh

    sudo chmod -R 600 /home/${1}/.ssh
    sudo chmod 700 /home/${1}/.ssh
    sudo chown -R ${1}:${1} /home/${1}/.ssh

    sudo chmod 644 /home/${1}/.bash_aliases
    sudo chown -R ${1}:${1} /home/${1}/.bash_aliases

    sudo mkdir -p /home/${1}/public_html
    sudo chmod 755 /home/${1}/public_html
    sudo chown -R ${1}:www-data /home/${1}/public_html

    sudo mkdir -p /home/${1}/.ssl
    sudo chown -R ${1}:${1} /home/${1}/.ssl
}

--user:config:admin() {
    echo "ductn ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/90-users >/dev/null
}
#!/usr/bin/env bash
#!/bin/bash

--version() {
    echo $(cat $_BASEDIR/version)
}

---v() {
    --version
}

--version:latest() {
    git archive --remote=git@bitbucket.org:DXVN/code.git master version | tar -xOf - >$DIRTMP/version
    echo $(cat $DIRTMP/version)
}

--version:islatest() {
    [[ "$(--version)" == "$(--version:latest)" ]] && echo 1 || echo 0
}
#!/usr/bin/env bash
#!/bin/bash

# _VPN_PATH=~/easy-rsa
_IPTUNEL="pve2:34.170.109.33"

_DUCTN_COMMANDS+=("vpn:init")
--vpn:init() {
    for vpn in $(--sys:env:list _IPTUNEL); do
        IFS=':' read -r -a array <<<$vpn
        hostname="${array[0]}"
        address="${array[1]}"

        --hosts:add $address "$hostname.vpn"

        [[ $(--host:name) == $hostname ]] && [[ "$(--vpn:type)" == "server" ]] && --vpn:server:init $hostname
        [[ $(--host:name) == $hostname ]] && [[ "$(--vpn:type)" == "client" ]] && --vpn:client:init $address $hostname
    done
}

--vpn:server:init() {
    hostname=$@

    if [ "$(--sys:service:isactive "openvpn-server@server.service")" == "inactive" ]; then
        # --vpn:openvpn
        echo -e "Please run command 'ductn vpn:openvpn'"

        # sudo openvpn --genkey --secret /etc/openvpn/server/ta.key
        #         echo -e "# Site-to-site
        # client-config-dir /etc/openvpn/ccd
        # tls-auth ta.key 0" | sudo tee -a /etc/openvpn/server/server.conf
    fi

    # push config to client
    if [[ -f /etc/openvpn/server/server.conf ]]; then
        sudo mkdir -p /etc/openvpn/ccd
        #     if [[ ! -n $(grep -P "client-config-dir" /etc/openvpn/server/server.conf) ]]; then
        #         echo -e "client-config-dir /etc/openvpn/ccd" | sudo tee -a /etc/openvpn/server/server.conf >/dev/null
        #     else
        #         sudo sed -i 's/client-config-dir .*/client-config-dir \/etc\/openvpn\/ccd/' /etc/openvpn/server/server.conf >/dev/null
        #     fi
        echo "ifconfig-push 10.8.0.2 255.255.255.0" | sudo tee /etc/openvpn/ccd/$hostname >/dev/null
    fi

}

--vpn:client:init() {
    address=$1
    hostname=$2
    --sys:apt:install openvpn
    sudo sed -i 's/.*AUTOSTART="all".*/AUTOSTART="all"/' /etc/default/openvpn >/dev/null

    ssh $address "sudo cat /root/$hostname.ovpn" | sudo tee /etc/openvpn/$hostname.conf >/dev/null

    # sudo openvpn --config ~/$hostname.ovpn
    # sudo cp ~/$hostname.ovpn /etc/openvpn/$hostname.conf

    # Authenicate by pass
    # check ‘auth-user-pass’ to ‘auth-user-pass pass’ in ovpn
    # echo -e "<IVPN Account ID>\n<IVPN Account Pass>" | sudo tee /etc/openvpn/pass >/dev/null
    # sudo chmod 400 /etc/openvpn/pass

    sudo systemctl enable openvpn@$hostname.service
    sudo systemctl daemon-reload
    sudo systemctl restart openvpn@$hostname.service

    # --vpn:openvpn
    # cd $_VPN_PATH
    # mkdir -p $_VPN_PATH/pki/reqs/
    # $_VPN_PATH/easyrsa init-pki
    # $_VPN_PATH/easyrsa gen-req server nopass

    # scp $serve:$_VPN_PATH/pki/reqs/server.req $DIRTMP/server.req
    # $_VPN_PATH/easyrsa import-req $DIRTMP/server.req server
    # $_VPN_PATH/easyrsa build-ca
    # $_VPN_PATH/easyrsa sign-req server server

    # [ ! -x "$(command -v autossh)" ] && --sys:apt:install autossh
    # source /etc/network/interfaces.d/*

    # autossh -M 0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -NTC -o Tunnel=point-to-point -w 0:0 $@ &
    # echo "autossh -M 0 -o \"ServerAliveInterval 30\" -o \"ServerAliveCountMax 3\" -NTC -o Tunnel=point-to-point -w 0:0 $@"
}

--vpn:type() {
    if [[ "$(--host:domain)" == "diepxuan.com" ]]; then
        echo "client"
    elif [[ "$(--host:domain)" == "vpn" ]]; then
        echo "server"
    else
        echo "none"
    fi
}

--vpn:openvpn() {
    [ ! -d $USER_BIN_PATH ] && mkdir -p $USER_BIN_PATH
    if [ -z $(command -v openvpn-ubuntu-installer.sh) ]; then
        wget https://git.io/vpn -O $USER_BIN_PATH/openvpn-ubuntu-installer.sh
        chmod +x $USER_BIN_PATH/openvpn-ubuntu-installer.sh
    fi
    [ ! -z "$(command -v openvpn-ubuntu-installer.sh)" ] && sudo $(command -v openvpn-ubuntu-installer.sh)
}
#!/usr/bin/env bash
#!/bin/bash

--wsl:cli:install() {
    if grep -q Microsoft /proc/version; then
        _wsl:cli:install
    fi
    if grep -q microsoft /proc/version; then
        _wsl:cli:install
    fi
}

_wsl:cli:install() {
    mkdir -p /mnt/c/wslcli/
    # cat /var/www/base/bash/win10/php.bat >/mnt/c/wslcli/php.bat
    cat /var/www/base/bash/win10/composer.bat >/mnt/c/wslcli/composer.bat

    wget https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar -O /mnt/c/wslcli/phpcs
    cat /var/www/base/bash/win10/phpcs.bat >/mnt/c/wslcli/phpcs.bat

    wget https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar -O /mnt/c/wslcli/phpcbf
    cat /var/www/base/bash/win10/phpcbf.bat >/mnt/c/wslcli/phpcbf.bat

    wget https://cs.symfony.com/download/php-cs-fixer-v3.phar -O /mnt/c/wslcli/php-cs-fixer
    cat /var/www/base/bash/win10/php-cs-fixer.bat >/mnt/c/wslcli/php-cs-fixer.bat

    # cat /var/www/base/bash/win10/node.bat >/mnt/c/wslcli/node.bat
    cat /var/www/base/bash/win10/yarn.bat >/mnt/c/wslcli/yarn.bat

    cat /var/www/base/bash/win10/git.bat >/mnt/c/wslcli/git.bat

    if [[ ! -f "$(which shfmt)" ]]; then
        $(curl -fsSL https://raw.githubusercontent.com/chiefbiiko/shfmt-install/v0.1.0/install.sh | sh) -d .
        chmod +x shfmt
        sudo chown root:root shfmt
        sudo mv shfmt /usr/local/bin/shfmt
    fi
    cat /var/www/base/bash/win10/shfmt.bat >/mnt/c/wslcli/shfmt.bat
}


--install() {
    --sys:apt:install jq
    --sys:apt:install net-tools
    # --sys:apt:install resolvconf

    --sys:service:install
}

main() {
    main:init

    _version="$([ --version:islatest ] && echo ${Green} || echo ${Red})$(--version)${NC}"

    --echo "Server\t\t$(--host:fullname)($(--host:address))"
    --echo "IP\t\t$(--ip:wan)"
    --echo "Version\t\t$_version (latest $(--version:latest))"
    # --host:domain

    # printf "%s " "Press enter to continue"
    # read ans

    # read -t 5 -n 1 -s -r -p "Press any key to continue (5 seconds)"
    # --echo \n
    exit 0
}

main:init() {
    --log:config
}

[[ ! "$(whoami)" -eq "ductn" ]] && exit 1

--init

if [[ ! -z ${@+x} ]]; then
    "--$@"
    exit 0
else
    main
    exit 0
fi

exit 0
