#!/usr/bin/env bash
#!/bin/bash

--cron:cronjob:min() {
    --sys:service:valid
}

--cron:cronjob:5min() {
    --cloudflare:sync
}

--cron:cronjob:hour() {
    # --ufw:geoip:configuration
    --sys:service:valid
    --sys:env:sync
    # --sys:upgrade
}

--cron:cronjob:month() {
    # --ufw:geoip:configuration
    return 0
}
