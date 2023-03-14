#!/usr/bin/env bash
#!/bin/bash

--dev:build() {
    if [[ -d /var/www/base ]]; then
        cd /var/www/base
        dpkg-buildpackage
    fi
}

--dev:depack() {
    if [[ -d /var/www/base ]]; then
        cd /var/www/base
        debuild -S
    fi
}
