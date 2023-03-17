#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("dev:build(")
--dev:build() {
    dpkg-buildpackage
}

_DUCTN_COMMANDS+=("dev:source")
--dev:source() {
    dpkg-buildpackage -S
}
