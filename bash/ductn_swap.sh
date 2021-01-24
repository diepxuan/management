#!/bin/sh

--install() {
    sudo rm -rf /swapfile
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
}

--remove() {
    sudo swapoff -v /swapfile
    sudo rm /swapfile
}

-i() {
    --install
}

$@
