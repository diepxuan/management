#!/usr/bin/env bash
#!/bin/bash

set -e
# set -u
. $(dirname $(realpath "$BASH_SOURCE"))/head.sh

APT_CONF_FILE=/etc/apt/apt.conf.d/50build-deb-action

export DEBIAN_FRONTEND=noninteractive

cat | sudo tee "$APT_CONF_FILE" <<-EOF
APT::Get::Assume-Yes "yes";
APT::Install-Recommends "no";
Acquire::Languages "none";
quiet "yes";
EOF

start_group "add apt source"
# debconf has priority “required” and is indirectly depended on by some
# essential packages. It is reasonably safe to blindly assume it is installed.
printf "man-db man-db/auto-update boolean false\n" | sudo debconf-set-selections

# add repository for install missing depends
sudo apt install software-properties-common
sudo add-apt-repository ppa:caothu91/ppa -y

# echo "deb http://download.opensuse.org/repositories/openSUSE:/Tools/xUbuntu_$RELEASE/ /" | sudo tee /etc/apt/sources.list.d/openSUSE:Tools.list
# curl -fsSL https://download.opensuse.org/repositories/openSUSE:Tools/xUbuntu_$RELEASE/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/openSUSE_Tools.gpg >/dev/null
end_group

start_group "install source depends"
sudo apt-get update
# shellcheck disable=SC2086
sudo apt-get build-dep $INPUT_APT_OPTS -- "$source_dir"

# In theory, explicitly installing dpkg-dev would not be necessary. `apt-get
# build-dep` will *always* install build-essential which depends on dpkg-dev.
# But let’s be explicit here.
# shellcheck disable=SC2086
sudo apt-get install $INPUT_APT_OPTS -- dpkg-dev libdpkg-perl dput tree devscripts $INPUT_EXTRA_BUILD_DEPS
end_group
