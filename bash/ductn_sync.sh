#!/bin/bash

if [[ $1 = "on" ]]; then
    systemctl --user enable grive-timer@$(systemd-escape gdrive).timer
    systemctl --user start grive-timer@$(systemd-escape gdrive).timer
    systemctl --user enable grive-changes@$(systemd-escape gdrive).service
    systemctl --user start grive-changes@$(systemd-escape gdrive).service
fi

if [[ $1 = "off" ]]; then
    systemctl --user stop grive-timer@$(systemd-escape gdrive).timer
    systemctl --user disable grive-timer@$(systemd-escape gdrive).timer
    systemctl --user stop grive-changes@$(systemd-escape gdrive).service
    systemctl --user disable grive-changes@$(systemd-escape gdrive).service
fi

#systemctl --user stop grive-timer@$(systemd-escape /home/cloud/public_html/data/ductn).timer
#systemctl --user disable grive-timer@$(systemd-escape /home/cloud/public_html/data/ductn).timer
#systemctl --user stop grive-changes@$(systemd-escape /home/cloud/public_html/data/ductn).service
#systemctl --user disable grive-changes@$(systemd-escape /home/cloud/public_html/data/ductn).service
