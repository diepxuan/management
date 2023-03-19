#!/usr/bin/env bash
#!/bin/bash

--cron:cronjob:min() {
    --sys:service:valid
}

--cron:cronjob:5min() {
    --cloudflare:sync
}

--cron:cronjob:hour() {
    --sys:service:valid
    --sys:env:sync
}

--cron:cronjob:month() {
    return 0
}
