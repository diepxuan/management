#!/usr/bin/env bash
#!/bin/bash

set -e
# set -u
. $(dirname $(realpath "$BASH_SOURCE"))/head.sh

env() {
    param=$1
    value=$2
    if [ "$(cat $GITHUB_ENV | grep $param= 2>/dev/null | wc -l)" != "0" ]; then
        sed -i "s|$param=.*|$param=$value|" $GITHUB_ENV
    else
        echo "$param=$value" >>$GITHUB_ENV
    fi
}

env source_dir $(realpath ./src)
env source_var $(realpath ./var)
env source_lib $(realpath ./var/lib)
env dists_dir $(realpath ./dists)
env ci_dir $(dirname $(realpath "$BASH_SOURCE"))
env pwd_dir ${GITHUB_WORKSPACE:-$(pwd || dirname $(realpath "$0") || realpath .)}

# user evironment
env email ductn@diepxuan.com
env changelog $(realpath ./src/debian/changelog)
env control $(realpath ./src/debian/control)
env controlin $(realpath ./src/debian/control.in)
env rules $(realpath ./src/debian/rules)
env timelog "$(Lang=C date -R)"

# plugin
echo "repository: $repository"
owner=$(echo $repository | cut -d '/' -f1)
project=$(echo $repository | cut -d '/' -f2)
module=$(echo $project | sed 's/^php-//g')
echo "$owner - $project - $module"
env owner $owner
env project $project
env module $module

# os evironment
[[ -f /etc/os-release ]] && . /etc/os-release
[[ -f /etc/lsb-release ]] && . /etc/lsb-release
CODENAME=${CODENAME:-$DISTRIB_CODENAME}
CODENAME=${CODENAME:-$VERSION_CODENAME}
CODENAME=${CODENAME:-$UBUNTU_CODENAME}

RELEASE=${RELEASE:-$(echo $DISTRIB_DESCRIPTION | awk '{print $2}')}
RELEASE=${RELEASE:-$(echo $VERSION | awk '{print $1}')}
RELEASE=${RELEASE:-$(echo $PRETTY_NAME | awk '{print $2}')}
RELEASE=${RELEASE:-${DISTRIB_RELEASE}}
RELEASE=${RELEASE:-${VERSION_ID}}
RELEASE=$(echo "$RELEASE" | awk -F. '{print $1"."$2}')

DISTRIB=${DISTRIB:-$DISTRIB_ID}
DISTRIB=${DISTRIB:-$ID}
DISTRIB=$(echo "$DISTRIB" | awk '{print tolower($0)}')

env CODENAME $CODENAME
env RELEASE $RELEASE
env DISTRIB $DISTRIB

env OBS_USERNAME $OBS_USERNAME
env OBS_TOKEN $OBS_TOKEN
env OBS_PW $OBS_PW
env OBS_OPPW $OBS_OPPW

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
