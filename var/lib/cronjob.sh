#!/usr/bin/env bash
#!/bin/bash

--cron:cronjob:min() {
    --sys:service:valid
}

--cron:cronjob:5min() {
    --cron:install
    --sys:ufw
    --cloudflare:sync
}

--cron:cronjob:hour() {
    # --ufw:geoip:configuration
    --sys:service:valid
}

--cron:cronjob:month() {
    --ufw:geoip:configuration
}
