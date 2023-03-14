#!/usr/bin/env bash
#!/bin/bash

--sys:service:main() {
    timer=0
    while true; do
        sleep 1
        ((timer += 1))
        timer=$(($timer % 10))

        if [ $(date +%S) = 1 ]; then
            --cron:cronjob:min &
        fi

        if [ $(($(date +%M) % 5)) = 1 ]; then
            --cron:cronjob:5min &
        fi

        if [ $(($(date +%M) % 30)) = 1 ]; then
            --cron:cronjob:hour &
        fi
    done
}

--run_as_service() {
    --sys:service:main
}

_DUCTN_COMMANDS+=("sys:service:isactive")
--sys:service:isactive() { #SERVICE_NAME
    _SERVICE_NAME=ductnd
    if [[ ! -z ${@+x} ]]; then
        _SERVICE_NAME="$@"
    fi
    IS_ACTIVE=$(sudo systemctl is-active $_SERVICE_NAME)
    echo $IS_ACTIVE
}

_DUCTN_COMMANDS+=("sys:service:restart")
--sys:service:restart() { #SERVICE_NAME
    _SERVICE_NAME=ductnd
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

_DUCTN_SERVICE= <<EOF
[Unit]
Description=Ductn service
After=network-online.target network.target

[Service]
ExecStart=ductn run_as_service
User=ductn

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
Alias=ductnd.service
EOF

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
        #     sudo systemctl restart ductnd
        #     echo "Service restarted"
        # else

        # create service file
        # echo "Creating service file"
        echo -e _DUCTN_SERVICE | sudo tee /usr/lib/systemd/system/ductnd.service >/dev/null 2>&1
        # ls -la /usr/lib/systemd/system/ | grep ductn
        # ls -la /etc/systemd/system/ | grep ductn
        # restart daemon, enable and start service
        # echo "Reloading daemon and enabling service"
        sudo systemctl daemon-reload
        sudo systemctl enable ductnd # remove the extension
        sudo systemctl restart ductnd
        # sudo systemctl status ductnd
    # echo "Service Started"
    # echo "aaa" | sudo tee /etc/systemd/system/ductn.service
    fi
}

_DUCTN_COMMANDS+=("sys:service:uninstall")
--sys:service:unistall() {
    sudo systemctl kill ductnd    # remove the extension
    sudo systemctl stop ductnd    # remove the extension
    sudo systemctl disable ductnd # remove the extension
    sudo rm -rf /etc/systemd/system/*ductnd.service
    sudo rm -rf /usr/lib/systemd/system/*ductnd.service
}