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
    GITHUB_ENV=${GITHUB_ENV:-.env}
    param=$1
    value="${@:2}"
    grep -q "^$param=" $GITHUB_ENV &&
        sed -i "s|^$param=.*|$param=$value|" $GITHUB_ENV ||
        echo "$param=$value" >>$GITHUB_ENV
    export $param="$value"
    echo $param: $value
}
# SUDO=sudo
# command -v sudo &>/dev/null || SUDO=''
run_as_sudo() {
    _SUDO=sudo
    command -v sudo &>/dev/null || _SUDO=''
    echo "Running as sudo: $*"
    if [[ $EUID -ne 0 ]]; then
        $_SUDO $@
    else
        $@
    fi
}
SUDO=${SUDO:-'run_as_sudo'}

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
env GIT_COMMITTER_MESSAGE $GIT_COMMITTER_MESSAGE

# gpg key
env GPG_KEY_ID $GPG_KEY_ID
env GPG_KEY $GPG_KEY
env DEB_SIGN_KEYID $DEB_SIGN_KEYID

# debian
env changelog $(realpath $debian_dir/changelog)
env control $(realpath $debian_dir/control)
env controlin $(realpath $debian_dir/control.in)
env rules $(realpath $debian_dir/rules)
env timelog "$(Lang=C date -R)"

# plugin
env repository ${repository:-diepxuan/$MODULE}
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

cd $source_dir

start_group Fix apt sources
# SOURCES="/etc/apt/sources.list"
# BACKUP="${SOURCES}.bak"
APT_CONF="/etc/apt/apt.conf.d/99archive"

# Kiểm tra xem là Debian Buster
# if grep -q "buster" /etc/os-release; then
if [[ "$CODENAME" == "buster" ]]; then
    # echo "🛠 Debian Buster detected"

    # Backup sources.list
    # if [ ! -f "$BACKUP" ]; then
    #     $SUDO cp /etc/apt/sources.list "$BACKUP"
    #     # echo "✅ Backup created: $BACKUP"
    # fi
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    mkdir -p /etc/apt/backup
    cp -a /etc/apt/sources.list /etc/apt/backup/sources.list.$TIMESTAMP 2>/dev/null || true
    cp -a /etc/apt/sources.list.d /etc/apt/backup/sources.list.d.$TIMESTAMP 2>/dev/null || true

    # Replace deb.debian.org -> archive.debian.org
    $SUDO sed -i \
        -e 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' \
        -e 's|http://deb.debian.org/debian-security|http://archive.debian.org/debian-security|g' \
        /etc/apt/sources.list
    # echo "✅ sources.list updated to archive.debian.org"

    # Remove buster-updates
    $SUDO sed -i '/buster\/updates/d' /etc/apt/sources.list
    $SUDO sed -i '/buster-updates/d' /etc/apt/sources.list


    # Disable Check-Valid-Until
    echo 'Acquire::Check-Valid-Until "0";' | $SUDO tee "$APT_CONF" >/dev/null
    # echo "✅ Created $APT_CONF"

    # Update package lists
    # $SUDO apt-get update
fi

# --- Adjust for Ubuntu 24.10 ---
if [[ "$RELEASE" == "20.10" ]]; then
    sudo sed -i 's|archive.ubuntu.com/ubuntu|old-releases.ubuntu.com/ubuntu|g' /etc/apt/sources.list
    sudo sed -i 's|security.ubuntu.com/ubuntu|old-releases.ubuntu.com/ubuntu|g' /etc/apt/sources.list
    # sed -i 's/debhelper-compat (= 12)/debhelper-compat (= 11)/' debian/control || true
fi

# Ensure curl or wget exists
if command -v curl >/dev/null 2>&1; then
    FETCH="curl -fs -o /dev/null -w %{http_code}"
elif command -v wget >/dev/null 2>&1; then
    FETCH="wget --spider --server-response --quiet --output-document=-"
else
    echo "⚙️ Installing curl..."
    apt update || true
    apt install -y curl || true
    FETCH="curl -fs -o /dev/null -w %{http_code}"
fi
# Check repository availability
HTTP_CODE=$($FETCH "http://archive.ubuntu.com/ubuntu/dists/$CODENAME/Release" 2>/dev/null | tail -n1 | grep -oE '[0-9]{3}' | head -n1)

# Check if archive.ubuntu.com still accessible
# if ! curl -fsI "http://archive.ubuntu.com/ubuntu/dists/$CODENAME/Release" >/dev/null 2>&1; then
if [ "$HTTP_CODE" != "200" ]; then
    echo "⚠️ Repo $CODENAME không còn tồn tại trên archive.ubuntu.com"
    echo "➡️  Sẽ chuyển sang old-releases.ubuntu.com"

    # Backup sources.list và các file repo
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    mkdir -p /etc/apt/backup
    cp -a /etc/apt/sources.list /etc/apt/backup/sources.list.$TIMESTAMP 2>/dev/null || true
    cp -a /etc/apt/sources.list.d /etc/apt/backup/sources.list.d.$TIMESTAMP 2>/dev/null || true

    # Xử lý định dạng cũ (.list)
    if grep -Rq "archive.ubuntu.com" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null; then
        echo "🛠  Cập nhật file .list cũ..."
        sed -i 's|http://archive.ubuntu.com/ubuntu|http://old-releases.ubuntu.com/ubuntu|g' /etc/apt/sources.list 2>/dev/null || true
        sed -i 's|http://security.ubuntu.com/ubuntu|http://old-releases.ubuntu.com/ubuntu|g' /etc/apt/sources.list 2>/dev/null || true
        sed -i 's|http://archive.ubuntu.com/ubuntu|http://old-releases.ubuntu.com/ubuntu|g' /etc/apt/sources.list.d/*.list 2>/dev/null || true
        sed -i 's|http://security.ubuntu.com/ubuntu|http://old-releases.ubuntu.com/ubuntu|g' /etc/apt/sources.list.d/*.list 2>/dev/null || true
    fi

    # Xử lý định dạng mới (.sources, deb822)
    if ls /etc/apt/sources.list.d/*.sources >/dev/null 2>&1; then
        echo "🛠  Cập nhật file .sources (deb822 format)..."
        for src in /etc/apt/sources.list.d/*.sources; do
            sed -i 's|http://archive.ubuntu.com/ubuntu|http://old-releases.ubuntu.com/ubuntu|g' "$src"
            sed -i 's|http://security.ubuntu.com/ubuntu|http://old-releases.ubuntu.com/ubuntu|g' "$src"
        done
    fi

    echo "✅ Repo sources đã được cập nhật."
else
    echo "✅ Repo $CODENAME vẫn còn hoạt động, không cần thay đổi."
fi

ls -lah /etc/apt/
ls -lah /etc/apt/sources.list.d/
cat /etc/apt/sources.list || true
cat /etc/apt/sources.list.d/ubuntu.sources || true
end_group


start_group Install Build Source Dependencies
APT_CONF_FILE=/etc/apt/apt.conf.d/50build-deb-action

cat | $SUDO tee "$APT_CONF_FILE" <<-EOF
APT::Get::Assume-Yes "yes";
APT::Install-Recommends "no";
Acquire::Languages "none";
quiet "yes";
EOF

# debconf has priority “required” and is indirectly depended on by some
# essential packages. It is reasonably safe to blindly assume it is installed.
printf "man-db man-db/auto-update boolean false\n" | $SUDO debconf-set-selections

$SUDO apt update || true
$SUDO apt-get install -y build-essential debhelper fakeroot gnupg reprepro wget curl git sudo vim locales lsb-release
$SUDO apt-get -y install lsb-release ca-certificates curl
$SUDO apt-get install -y python3 python3-pip python3-venv gcc python3-dev
$SUDO apt-get install -y debhelper dh-python python3-all python3-setuptools

# [[ ! -f /usr/share/keyrings/microsoft-prod.gpg ]] && {
#     [[ ! -f /etc/apt/trusted.gpg.d/microsoft.asc ]] && {
#         curl -fsSL https://packages.microsoft.com/keys/microsoft.asc |
#             $SUDO tee /etc/apt/trusted.gpg.d/microsoft.asc >/dev/null ||
#             echo "Failed to download Microsoft key to /etc/apt/trusted.gpg.d/microsoft.asc"
#     }

#     [[ -f /etc/apt/trusted.gpg.d/microsoft.asc ]] && {
#         cat /etc/apt/trusted.gpg.d/microsoft.asc |
#             $SUDO gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg ||
#             echo "Failed to dearmor key from /etc/apt/trusted.gpg.d/microsoft.asc"
#     } || {
#         curl -fsSL https://packages.microsoft.com/keys/microsoft.asc |
#             $SUDO gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg ||
#             echo "Failed to download and dearmor Microsoft key to /usr/share/keyrings/microsoft-prod.gpg"
#     }
# }

# [[ ! -f /etc/apt/sources.list.d/prod.list ]] &&
#     ! grep -q 'https://packages.microsoft.com' /etc/apt/sources.list /etc/apt/sources.list.d/* &&
#     echo https://packages.microsoft.com/config/$DISTRIB/$RELEASE/prod.list &&
#     curl -fsSL https://packages.microsoft.com/config/$DISTRIB/$RELEASE/prod.list |
#     $SUDO tee /etc/apt/sources.list.d/prod.list >/dev/null

# add repository for install missing depends
# if [[ $DISTRIB == "ubuntu" ]]; then
#     $SUDO apt install software-properties-common
#     $SUDO add-apt-repository ppa:ondrej/php -y
# elif [[ $DISTRIB == "debian" ]]; then
#     ${SUDO} curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb
#     ${SUDO} dpkg -i /tmp/debsuryorg-archive-keyring.deb
#     echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $CODENAME main" |
#         $SUDO tee /etc/apt/sources.list.d/php.list >/dev/null
# fi

$SUDO apt update || true
# In theory, explicitly installing dpkg-dev would not be necessary. `apt-get
# build-dep` will *always* install build-essential which depends on dpkg-dev.
# But let’s be explicit here.
# shellcheck disable=SC2086
$SUDO apt install -y debhelper-compat dpkg-dev libdpkg-perl dput tree devscripts
$SUDO apt install -y libdistro-info-perl
$SUDO apt install $INPUT_APT_OPTS -- $INPUT_EXTRA_BUILD_DEPS

# shellcheck disable=SC2086
$SUDO apt build-dep $INPUT_APT_OPTS -- "$source_dir" || true
$SUDO apt-get build-dep -y -- "$source_dir" || true
end_group

start_group "GPG/SSH Configuration"
if ! gpg --list-keys --with-colons | grep -q "fpr"; then
    echo "$GPG_KEY====" | tr -d '\n' | fold -w 4 | sed '$ d' | tr -d '\n' | fold -w 76 | base64 -di | gpg --batch --import || true
fi

#!/bin/bash

# Lấy danh sách tất cả GPG key IDs
KEYS=$(gpg --list-secret-keys --keyid-format=long | awk '/sec/{print $2}' | cut -d'/' -f2)

# Lặp qua từng key và chỉnh sửa
for KEY in $KEYS; do
    # Cập nhật expiration date của subkey
    gpg --batch --command-fd 0 --edit-key "$KEY" <<EOF
key 1
expire
0
save
EOF

    # Cập nhật expiration date của key chính
    gpg --batch --command-fd 0 --edit-key "$KEY" <<EOF
expire
0
save
EOF

    # Đặt key thành Ultimate Trust
    gpg --batch --command-fd 0 --edit-key "$KEY" <<EOF
trust
5
save
EOF
done

if gpg --list-secret-keys --keyid-format=long | grep -q "sec"; then
    export DEB_SIGN_KEYID=$(gpg --list-keys --with-colons --fingerprint | awk -F: '/fpr:/ {print $10; exit}')
fi
gpg --list-secret-keys --keyid-format=long
end_group

start_group View Source Code
echo $source_dir
ls -la $source_dir
echo $debian_dir
ls -la $debian_dir
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

start_group Python detect annotations
# Thêm `from __future__ import annotations` vào đầu file .py nếu Python <= 3.9

# Kiểm tra phiên bản Python
PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)

echo "[INFO] Detected Python version: $PYTHON_MAJOR.$PYTHON_MINOR"

if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 7 ] && [ "$PYTHON_MINOR" -le 9 ]; then
    # Chuỗi future import
    FUTURE_LINE="from __future__ import annotations"

    # Thư mục project (chỉnh lại nếu cần)
    PROJECT_DIR="$source_dir"

    # Duyệt tất cả file .py
    find "$PROJECT_DIR" -type f -name "*.py" | while read -r file; do
        # Kiểm tra xem file đã có future import chưa (chỉ kiểm tra 5 dòng đầu)
        if head -n 10 "$file" | grep -qF "$FUTURE_LINE"; then
            continue
        fi

        # Thêm dòng future vào đầu file
        sed -i "1i $FUTURE_LINE" "$file"
        echo "Added future import to $file"
    done
elif [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -le 6 ]; then
    echo "⚠️ Python <= 3.6, cần sửa type hints và không dùng | trong type hint"
    find "$source_dir" -type f -name "*.py" | while read f; do
        # text=$(cat "$f")
        text=$(<"$f")
        orig_text="$text"
        # a | b -> Union[a, b]
        text=$(echo "$text" | sed -E 's/([a-zA-Z0-9_]+)\s*\|\s*([a-zA-Z0-9_]+)/Union[\1, \2]/g')
        # list[...] -> List[...]
        text=$(echo "$text" | sed -E 's/list\[(.*)\]/List[\1]/g')
        # dict[...] -> Dict[...]
        text=$(echo "$text" | sed -E 's/dict\[(.*),(.*)\]/Dict[\1, \2]/g')
        # collections.abc.Iterator -> typing.Iterator
        text=$(echo "$text" | sed -E 's|from collections.abc import Iterator|from typing import Iterator|g')

        # 5. Nếu file thay đổi, thêm import typing nếu cần
        if [ "$text" != "$orig_text" ]; then
            # Thêm import nếu file changed
            if ! grep -q "from typing import" <<< "$text"; then
                text="from typing import List, Dict, Union, Iterator"$'\n'"$text"
            else
                # Thêm thiếu List, Dict, Union, Iterator vào dòng import hiện tại
                text=$(echo "$text" | sed -E 's/from typing import (.*)/from typing import \1, List, Dict, Union/')
            fi
            echo "$text" > "$f"
        fi
    done

    echo "✅ Type hints fixed"
fi

end_group

start_group Update Package Configuration in Changelog
# Determine release_tag and package_clog from GitHub events or fallback to changelog

# Helper function to check if string is empty or only contains whitespace
is_empty_or_whitespace() {
    local str="$1"
    [[ -z "${str// }" ]] && [[ -z "${str//\t}" ]] && [[ -z "${str//\n}" ]] && return 0
    return 1
}

CHANGELOG_VERSION=$(head -n 1 "$changelog" | awk '{print $2}' | sed 's|[()]||g')
CHANGELOG_BASE_VERSION=${CHANGELOG_VERSION%%+*}

# Default to the source changelog version. CI for branch/PR builds must not
# downgrade a release branch by reusing the previous GitHub release tag.
release_tag="$CHANGELOG_BASE_VERSION"

# Get changelog notes (line 3 to before the -- line)
CHANGELOG_NOTES=$(sed -n '3,/^ -- /p' "$changelog" | sed '$d' | sed 's/^[ \t]*//;s/[ \t]*$//')

# Only release/tag builds are allowed to override changelog values from GitHub
# release metadata. Push and pull_request builds should validate the branch as-is.
if [[ "$GITHUB_EVENT_NAME" == "release" ]] || [[ -n "$GITHUB_REF" && "$GITHUB_REF" == refs/tags/* ]]; then
    REPO_OWNER=$(echo $repository | cut -d '/' -f1)
    REPO_NAME=$(echo $repository | cut -d '/' -f2)

    if [[ -n "$GITHUB_REF" && "$GITHUB_REF" == refs/tags/* ]]; then
        TAG_NAME=${GITHUB_REF#refs/tags/}
        RELEASE_INFO=$(curl -s "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/${TAG_NAME}")
    else
        RELEASE_INFO=$(curl -s "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest")
    fi

    if [[ -n "$RELEASE_INFO" ]]; then
        RELEASE_TAG=$(echo "$RELEASE_INFO" | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4 | sed 's/^v//')
        RELEASE_BODY=$(echo "$RELEASE_INFO" | grep -o '"body": "[^"]*"' | cut -d'"' -f4 | sed 's/\\n/\n/g; s/\\r//g')

        if ! is_empty_or_whitespace "$RELEASE_TAG"; then
            release_tag="$RELEASE_TAG"
            echo "release_tag from GitHub release: $release_tag"
        fi

        if ! is_empty_or_whitespace "$RELEASE_BODY"; then
            package_clog="$RELEASE_BODY"
            echo "package_clog from GitHub release: $package_clog"
        fi
    fi
fi

is_empty_or_whitespace "$release_tag" && release_tag="$CHANGELOG_BASE_VERSION"
is_empty_or_whitespace "$package_clog" && package_clog="$CHANGELOG_NOTES"
is_empty_or_whitespace "$package_clog" && package_clog='Update package'

package_version="$release_tag+$DISTRIB~$RELEASE"
current_version=$(dpkg-parsechangelog -l "$changelog" -S Version 2>/dev/null || echo "$CHANGELOG_VERSION")

if dpkg --compare-versions "$package_version" eq "$current_version"; then
    echo "release_tag: $package_version"
    echo "package_clog: $package_clog"
    echo "Changelog already has target package version; skipping dch update."
else
    echo "release_tag: $package_version"
    echo "package_clog: $package_clog"
    dch --package $owner --newversion "$package_version" --distribution $CODENAME -- "$package_clog"
fi
end_group

start_group Show log
echo $control
cat $control || true
echo $controlin
cat $controlin || true
echo $rules
cat $rules || true
end_group

start_group Show changelog
cat $changelog
end_group

start_group Show package changelog
echo $package_clog
end_group

start_group log GPG key before build
gpg --list-secret-keys --keyid-format=long
end_group

start_group Building package binary
dpkg-parsechangelog
# shellcheck disable=SC2086
dpkg-buildpackage --force-sign || dpkg-buildpackage --force-sign -d
# shellcheck disable=SC2086
dpkg-buildpackage --force-sign -S || dpkg-buildpackage --force-sign -S -d
end_group

start_group Move build artifacts
regex='^php.*(.deb|.ddeb|.buildinfo|.changes|.dsc|.tar.xz|.tar.gz|.tar.[[:alpha:]]+)$'
regex='.*(.deb|.ddeb|.buildinfo|.changes|.dsc|.tar.xz|.tar.gz|.tar.[[:alpha:]]+)$'
mkdir -p $dists_dir

while read -r file; do
    mv -vf "$source_dir/$file" "$dists_dir/" || true
done < <(ls $source_dir/ | grep -E $regex)

while read -r file; do
    mv -vf "$pwd_dir/$file" "$dists_dir/" || true
done < <(ls $pwd_dir/ | grep -E $regex)

ls -la $dists_dir
end_group

start_group Publish Package to Launchpad
cat | tee ~/.dput.cf <<-EOF
[caothu91ppa]
fqdn = ppa.launchpad.net
method = ftp
incoming = ~caothu91/ubuntu/ppa/
login = anonymous
allow_unsigned_uploads = 0
EOF

# package=$(ls -a $dists_dir | grep _source.changes | head -n 1)

# [[ -n $package ]] &&
#     package=$dists_dir/$package &&
#     [[ -f $package ]] &&
#     dput caothu91ppa $package || true

while read -r package; do
    dput caothu91ppa $dists_dir/$package || true
done < <(ls $dists_dir | grep -E '.*(_source.changes)$')
end_group
