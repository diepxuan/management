#!/usr/bin/env bash
#!/bin/bash

set -e
# set -u
. $(dirname $(realpath "$BASH_SOURCE"))/head.sh

mkdir -p ~/.config/osc
cat | tee ~/.config/osc/oscrc <<-EOF
[general]
apiurl = https://api.opensuse.org
# plaintext_passwd = 0

[https://api.opensuse.org]
user=$OBS_USERNAME
pass=$OBS_OPPW
credentials_mgr_class=osc.credentials.ObfuscatedConfigFileCredentialsManager
# user=$OBS_USERNAME
# pass=$OBS_PW
# credentials_mgr_class=osc.credentials.PlaintextConfigFileCredentialsManager
# username = $OBS_USERNAME
# password = $OBS_OPPW
EOF

start_group "create obs package dists"
osc checkout home:diepxuan/ductn
obs_dir=$(realpath home\:diepxuan/ductn)
end_group

start_group "move package builder to dists"
cp -r $dists_dir/* home\:diepxuan/ductn/
ls -la $obs_dir
end_group

start_group "move package builder to dists"
cd $obs_dir
alien -r your-package.deb
rm -rf *ppa.upload
rm -rf *.deb
ls -la $obs_dir
end_group

start_group "put package to obs"
cd $obs_dir
osc addremove
osc ci -m "Update from GitHub"
end_group
