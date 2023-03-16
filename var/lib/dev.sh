#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("dev:build(")
--dev:build() {
    dpkg-buildpackage
}

_DUCTN_COMMANDS+=("dev:buildsource")
--dev:buildsource() {
    dpkg-buildpackage -S
}
