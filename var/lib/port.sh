#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("port:open")
--port:open() {
    sudo lsof -nP | grep LISTEN
}
