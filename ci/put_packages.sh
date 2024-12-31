#!/usr/bin/env bash
#!/bin/bash

set -e
# set -u
. $(dirname $(realpath "$BASH_SOURCE"))/head.sh

start_group "put package to DiepXuan PPA"
git clone --depth 1 --branch main git@github.com:diepxuan/ppa.git
cp -r $dists_dir/*.deb $ppa_dir/dists/
cd $ppa_dir
git add dists/
git commit -m "Add .deb package"
git push origin main
end_group
