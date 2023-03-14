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
}

--cron:cronjob:hour() {
    # --ufw:geoip:configuration
    --cron:service
}

--cron:cronjob:month() {
    --ufw:geoip:configuration
}

_DUCTN_COMMANDS+=("cron:update")
--cron:update() {
    --cron:cronjob:5min
}
