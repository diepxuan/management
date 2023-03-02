#!/usr/bin/env bash
#!/bin/bash

--version() {
    echo $(cat $_BASEDIR/version)
}

---v() {
    --version
}

--version:latest() {
    git archive --remote=git@bitbucket.org:DXVN/code.git master version | tar -xOf - >$DIRTMP/version
    echo $(cat $DIRTMP/version)
}

--version:islatest() {
    [[ "$(--version)" == "$(--version:latest)" ]] && echo 1 || echo 0
}
