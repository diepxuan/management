#!/usr/bin/env bash
#!/bin/bash

--cron:cronjob:min() {
    --sys:service:valid
}

--cron:cronjob:5min() {
    --sys:ufw
    --sys:service:iptables

    --cloudflare:sync
}

--cron:cronjob:hour() {
    # --ufw:geoip:configuration
    --sys:service:valid
}

--cron:cronjob:month() {
    --ufw:geoip:configuration
}
