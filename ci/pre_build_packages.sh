#!/usr/bin/env bash
#!/bin/bash

set -e
# set -u
. $(dirname $(realpath "$BASH_SOURCE"))/head.sh

cat $source_lib/m2 >>$source_dir/ductn

cat $source_var/ductn >>$source_dir/ductn
cat $source_var/m2 >$source_dir/m2
