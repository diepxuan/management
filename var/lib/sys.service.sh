#!/usr/bin/env bash
#!/bin/bash

--sys:service:main() {
    timer=0
    while true; do
        sleep 1
        ((timer += 1))
        timer=$(($timer % 10))

        # execute every minute
        if [[ $(date +%S) == 1 ]]; then
            --cron:cronjob:min
        fi

        # execute every 5mins
        if [[ $(($(date +%M) % 5)) == 1 ]]; then
            --cron:cronjob:5min
        fi

        # execute every 30mins
        if [[ $(($(date +%M) % 30)) == 1 ]]; then
            --cron:cronjob:hour
        fi
    done
}

--run_as_service() {
    _SERVICE_NAME=ductnd
    if [ ! "$(--sys:service:isactive $_SERVICE_NAME)" == "active" ]; then
        sudo systemctl stop ${_SERVICE_NAME//'.service'/}
        sudo systemctl start ${_SERVICE_NAME//'.service'/}
    else
        --sys:service:main
    fi
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
        # echo -e "$_DUCTN_SERVICE" | sudo tee /usr/lib/systemd/system/ductnd.service >/dev/null 2>&1
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
