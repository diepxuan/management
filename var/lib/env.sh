#!/usr/bin/env bash
#!/bin/bash

--sys:env() {
    echo -e $* | xargs
}

--sys:env:domains() {
    cat $ETC_PATH/domains
}

--sys:env:nat() {
    cat $ETC_PATH/nat
}

--sys:env:vpn() {
    cat $ETC_PATH/tunel
}
