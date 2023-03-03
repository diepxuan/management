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
}
