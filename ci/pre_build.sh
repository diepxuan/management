#!/usr/bin/env bash
#!/bin/bash

set -e
# set -u
. $(dirname $(realpath "$BASH_SOURCE"))/head.sh

cat $source_lib/php.m2.sh >>$source_dir/ductn
cat $source_lib/git.sh >>$source_dir/ductn

cat $source_var/ductn >>$source_dir/ductn
cat $source_var/m2 >$source_dir/m2

mkdir -p $source_dir/lib/
curl -Lo $source_dir/lib/phpactor.phar https://github.com/phpactor/phpactor/releases/latest/download/phpactor.phar
