#!/usr/bin/env bash
#!/bin/bash

set -e
# set -u
. $(dirname $(realpath "$BASH_SOURCE"))/head.sh

mkdir ~/.ssh/
chmod 700 ~/.ssh
echo "$SSH_ID_RSA" >~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
ssh-keygen -f ~/.ssh/id_rsa -y >~/.ssh/id_rsa.pub

start_group "put package to DiepXuan PPA"

git clone --depth 1 --branch main git@github.com:diepxuan/ppa.git
cp -r $dists_dir/*.deb $ppa_dir/dists/
cd $ppa_dir
git add dists/
git commit -m "Add .deb package"
git push origin main
end_group
