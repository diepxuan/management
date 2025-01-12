#!/usr/bin/env bash
#!/bin/bash

set -e
# set -u

export DEBIAN_FRONTEND=noninteractive

# Usage:
#   error MESSAGE
error() {
    echo "::error::$*"
}

# Usage:
#   end_group
end_group() {
    echo "::endgroup::"
}

# Usage:
#   start_group GROUP_NAME
start_group() {
    echo "::group::$*"
}

env() {
    param=$1
    value="${@:2}"
    grep -q "^$param=" $GITHUB_ENV &&
        sed -i "s|^$param=.*|$param=$value|" $GITHUB_ENV ||
        echo "$param=$value" >>$GITHUB_ENV
    export $param="$value"
    echo $param: $value
}

start_group Dynamically set environment variable
# directory
env source_dir $(dirname $(realpath "$BASH_SOURCE"))
env source_var $(realpath $source_dir/var)
env source_lib $(realpath $source_dir/var/lib)
env debian_dir $(realpath $source_dir/debian)
env pwd_dir $(realpath $(dirname $source_dir))
env dists_dir $(realpath $pwd_dir/dists)
env ppa_dir $(realpath $pwd_dir/ppa)

# user evironment
env email ductn@diepxuan.com
env DEBEMAIL ductn@diepxuan.com
env EMAIL ductn@diepxuan.com
env DEBFULLNAME Tran Ngoc Duc
env NAME Tran Ngoc Duc

# gpg key
env GPG_KEY_ID $GPG_KEY_ID
env DEB_SIGN_KEYID $(gpg --list-keys --with-colons --fingerprint | awk -F: '/fpr:/ {print $10; exit}')
# env DEB_SIGN_KEYID $DEB_SIGN_KEYID

# debian
env changelog $(realpath $debian_dir/changelog)
env control $(realpath $debian_dir/control)
env controlin $(realpath $debian_dir/control.in)
env rules $(realpath $debian_dir/rules)
env timelog "$(Lang=C date -R)"

# plugin
env repository $repository
env owner $(echo $repository | cut -d '/' -f1)
env project $(echo $repository | cut -d '/' -f2)
env module $(echo $project | sed 's/^php-//g')

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
# RELEASE=$(echo "$RELEASE" | awk -F. '{print $1"."$2}')
RELEASE=$(echo "$RELEASE" | cut -d. -f1-2)
RELEASE=$(echo "$RELEASE" | tr '[:upper:]' '[:lower:]')
RELEASE=${RELEASE//[[:space:]]/}
RELEASE=${RELEASE%.}

DISTRIB=${DISTRIB:-$DISTRIB_ID}
DISTRIB=${DISTRIB:-$ID}
DISTRIB=$(echo "$DISTRIB" | tr '[:upper:]' '[:lower:]')

env CODENAME $CODENAME
env RELEASE $RELEASE
env DISTRIB $DISTRIB
end_group

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
# sudo add-apt-repository ppa:caothu91/ppa -y

# echo "deb http://download.opensuse.org/repositories/openSUSE:/Tools/xUbuntu_$RELEASE/ /" | sudo tee /etc/apt/sources.list.d/openSUSE:Tools.list
# curl -fsSL https://download.opensuse.org/repositories/openSUSE:Tools/xUbuntu_$RELEASE/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/openSUSE_Tools.gpg >/dev/null
end_group

start_group "add obs source"
# wget -qO - https://download.opensuse.org/repositories/openSUSE:/Tools/Debian_$(lsb_release -sc)/Release.key | sudo apt-key add -
# echo "deb http://download.opensuse.org/repositories/openSUSE:/Tools/Debian_$(lsb_release -sc)/ ./" | sudo tee /etc/apt/sources.list.d/obs.list
# sudo apt install -y osc
# sudo apt install -y alien rpm
# sudo apt install -y build-essential python3-dev libssl-dev libffi-dev
# pip3 install M2Crypto
# pip3 install --upgrade osc
end_group

start_group "install source depends"
sudo apt update
# shellcheck disable=SC2086
sudo apt-get build-dep $INPUT_APT_OPTS -- "$source_dir"

# In theory, explicitly installing dpkg-dev would not be necessary. `apt-get
# build-dep` will *always* install build-essential which depends on dpkg-dev.
# But let’s be explicit here.
# shellcheck disable=SC2086
sudo apt install $INPUT_APT_OPTS -- dpkg-dev libdpkg-perl dput tree devscripts $INPUT_EXTRA_BUILD_DEPS
sudo apt install $INPUT_APT_OPTS -- libdistro-info-perl $INPUT_EXTRA_BUILD_DEPS
end_group

# Update os release latest
# old_release_os=$(cat $changelog | head -n 1 | awk '{print $2}' | cut -d '+' -f2 | cut -d '~' -f1)
# sed -i -e "0,/$old_release_os/ s/$old_release_os/${DISTRIB}${RELEASE}/g" $changelog

# Update os codename
# old_codename_os=$(cat $changelog | head -n 1 | awk '{print $3}')
# sed -i -e "0,/$old_codename_os/ s/$old_codename_os/$CODENAME;/g" $changelog

# Update time building
# BUILDPACKAGE_EPOCH=${BUILDPACKAGE_EPOCH:-$(date -R)}
# sed -i -e "0,/<$email>  .*/ s/<$email>  .*/<$email>  $BUILDPACKAGE_EPOCH/g" $changelog

start_group "update package config"
cd $source_dir

release_tag=$($source_dir/ductn version:newrelease)

# old_project=$(cat $changelog | head -n 1 | awk '{print $1}' | sed 's|[()]||g')
# old_release_tag=$(cat $changelog | head -n 1 | awk '{print $2}' | sed 's|[()]||g')
# old_codename_os=$(cat $changelog | head -n 1 | awk '{print $3}' | sed 's|;||g')
package_clog=$(git log -1 --pretty=format:"%h %s" -- src/)
package_clog=${package_clog:-$GIT_COMMITTER_MESSAGE}
package_clog=${package_clog:-"Update package"}

# sed -i -e "s|$old_project|$_project|g" $changelog

# sed -i -e "s|$old_release_tag|$release_tag|g" $changelog
# sed -i -e "s|$old_codename_os|$CODENAME|g" $changelog
# sed -i -e "s|<$email>  .*|<$email>  $timelog|g" $changelog
# dch -D $CODENAME
# dch --newversion $release_tag~$DISTRIB$RELEASE --distribution $CODENAME "$package_clog"
dch --newversion $release_tag --distribution $CODENAME "$package_clog"
# dch --newversion $release_tag~$DISTRIB$RELEASE
# dch -a "$package_clog"
cd -
end_group

cd $source_dir
# shellcheck disable=SC2086
dpkg-buildpackage --force-sign
dpkg-buildpackage --force-sign -S
ls -la $source_dir
cd -
Dynamically set environment variable

if [ -n "$(git status src/debian/ --porcelain=v1 2>/dev/null)" ]; then
    git add src/debian/
    git commit -m "Update version at $(date +'%d-%m-%y')"
    if ! git push; then
        git stash
        git pull --rebase
        git stash pop
        git push || true
    fi
fi
# Put package to Personal Package archives

start_group "move package builder to dists"
regex='.*(.deb|.ddeb|.buildinfo|.changes|.dsc|.tar.xz|.tar.gz|.tar.[[:alpha:]]+)$'
mkdir -p $dists_dir

while read -r file; do
    cp -vf "$source_dir/$file" "$dists_dir/" || true
done < <(ls $source_dir/ | grep -E $regex)

while read -r file; do
    cp -vf "$pwd_dir/$file" "$dists_dir/" || true
done < <(ls $pwd_dir/ | grep -E $regex)
end_group

start_group "put package to ppa"
cat | tee ~/.dput.cf <<-EOF
[caothu91ppa]
fqdn = ppa.launchpad.net
method = ftp
incoming = ~caothu91/ubuntu/ppa/
login = anonymous
allow_unsigned_uploads = 0
EOF

release_package=$(cat $changelog | head -n 1 | awk '{print $1}')
release_version=$(cat $changelog | head -n 1 | awk '{print $2}' | sed 's|[()]||g')

package=$(ls -a $dists_dir | grep ${release_package}_${release_version} | grep _source.changes | head -n 1)
[[ -n $package ]] &&
    package=$dists_dir/$package &&
    [[ -f $package ]] &&
    dput caothu91ppa $package || true

ls -la $dists_dir
end_group

start_group "put package to DiepXuan PPA"
git clone --depth 1 --branch main git@github.com:diepxuan/ppa.git

package_clog=$(git log -1 --pretty=format:"%h %s" -- src/)
package_clog=${package_clog:-"Update at $(date +'%d-%m-%y')"}

rm -rf $ppa_dir/src/$repository
mkdir -p $ppa_dir/src/$repository/
cp -r $source_dir/. $ppa_dir/src/$repository/
cd $ppa_dir

if [ "$(git status src/ --porcelain=v1 2>/dev/null | wc -l)" != "0" ]; then
    git add src/
    git commit -m "$package_clog"
    git fetch -ap
    git pull --rebase -X ours
    git push origin HEAD:main
fi

end_group
