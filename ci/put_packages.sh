#!/usr/bin/env bash
#!/bin/bash

set -e
# set -u
. $(dirname $(realpath "$BASH_SOURCE"))/head.sh

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
