#!/usr/bin/env bash
#!/bin/bash

pwd_dir=${pwd_dir:-$(pwd)}
gitmess=$(git log --oneline -1 --pretty=%B)

__main() {
    git checkout -- src/
    while IFS= read -d $'\0' -r file; do
        __composer $file
    done < <(find src/Diepxuan src/Cloudflare -mindepth 1 -maxdepth 1 -type d -print0)
}

__composer() {
    local folder=${1:-"."}
    [[ ! -f $folder/composer.json ]] && return
    local package_name=$(cat $folder/composer.json | jq '.name')
    local package_url=$(composer show -a ${package_name//'"'/} | grep source | grep "\[git\] " | awk '{print $4}')
    package_url=${package_url//'https://github.com/'/'git@github.com:'}
    echo "$GIT_OWNER $GIT_TOKEN"
    if [[ (-z $GIT_OWNER) && (-z $GIT_TOKEN) ]]; then
        package_url=${package_url//'git@github.com:'/"https://$GIT_OWNER:$GIT_TOKEN@github.com/"}
        echo $package_url
    fi
    __git_init $folder $package_url
    __git_deinit $folder
}

__git_init() {
    local folder=$1
    local giturl=$2
    cd $folder
    git init
    git config pull.rebase true
    git checkout -b main
    git add .
    git commit -m "$gitmess"
    git remote add origin $giturl
    git fetch -ap
    git branch --set-upstream-to=origin/main main
    git pull --rebase -X theirs
    git push
    cd $pwd_dir
}

__git_deinit() {
    local folder=$1
    rm -rf $folder/.git
}

__main
