#!/usr/bin/env bash

# composer update --prefer-source --no-dev
# composer update
# composer clear-cache

# vps:

composer clear-cache
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
# composer update --no-dev --optimize-autoloader --prefer-dist
composer update
sudo swapoff --all
sudo rm -rf /swapfile

# free -h
