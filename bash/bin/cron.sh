#!/usr/bin/env bash
#!/bin/bash

--cron:cronjob:min() {
    --sys:service:cron
    --sys:vpn:cron
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
