#!/usr/bin/env bash
#!/bin/bash

set -e
# set -u
. $(dirname $(realpath "$BASH_SOURCE"))/head.sh

start_group "put package to buildkite"
mkdir -p $ppa_dir/dists/
cp -r $dists_dir/* $ppa_dir/dists/
cd $ppa_dir
git init
git remote add origin git@github.com:diepxuan/ppa.git
git add dists/
git commit -m "Add .deb package"
git push origin main
end_group
