#!/usr/bin/env bash
#!/bin/bash

d_port:open() {
    sudo lsof -nP | grep LISTEN
}
