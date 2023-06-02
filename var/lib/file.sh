#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("file:chmod")
--file:chmod() {
    stat -c "%a" $1
}
