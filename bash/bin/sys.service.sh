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

_DUCTN_COMMANDS+=("sys:service")
--sys:service() {
    if [ "$(--sys:service:isactive)" == "active" ]; then
        --cron:crontab:uninstall >/dev/null 2>&1
    fi
}

_DUCTN_COMMANDS+=("sys:service:isactive")
--sys:service:isactive() {
    _SERVICE_NAME=$SERVICE_NAME
    if [[ ! -z ${@+x} ]]; then
        _SERVICE_NAME="$@"
    fi
    IS_ACTIVE=$(sudo systemctl is-active $_SERVICE_NAME)
    echo $IS_ACTIVE
}

_DUCTN_COMMANDS+=("sys:service:restart")
--sys:service:restart() {
    if [ "$(--sys:service:isactive)" == "active" ]; then
        sudo systemctl restart ${SERVICE_NAME//'.service'/}
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
