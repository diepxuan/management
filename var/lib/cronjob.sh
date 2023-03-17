#!/usr/bin/env bash
#!/bin/bash

--cron:cronjob:min() {
    --sys:service:valid
    --ufw:iptables
}

--cron:cronjob:5min() {
    --sys:ufw

    --cloudflare:sync
}

--cron:cronjob:hour() {
    # --ufw:geoip:configuration
    --sys:service:valid
    --sys:env:sync
    # --sys:upgrade
}

--cron:cronjob:month() {
    --ufw:geoip:configuration
}
