#!/usr/bin/env bash
#!/bin/bash

_GITDIR="$_LIBDIR/git"

_DUCTN_COMMANDS+=("git:configure")
--git:configure() {
    if [[ -d $_BASEDIR/.git ]]; then
        # global gitignore
        git config --global core.excludesfile ~/.gitignore

        # setting
        git config --global user.name "Tran Ngoc Duc"
        git config --global user.email "caothu91@gmail.com"

        # alias
        git config --global alias.plog "log --graph --pretty=format:'%h -%d %s %n' --abbrev-commit --date=relative --branches"

        # push
        git config --global push.default simple

        # file mode
        git config --global core.fileMode false

        # line endings
        git config --global core.autocrlf false
        git config --global core.eol lf

        # Cleanup
        git config --global gc.auto 0

        # remote server
        git config --global receive.denyCurrentBranch updateInstead

        if [ "$(whoami)" = "ductn" ]; then
            cd $_BASEDIR

            cat $_GITDIR/.gitignore >~/.gitignore
            chmod 644 ~/.gitignore

            # remote repository
            cat $_GITDIR/push-to-checkout >$_BASEDIR/.git/hooks/push-to-checkout
            cat $_GITDIR/pre-commit >$_BASEDIR/.git/hooks/pre-commit
            rm -rf $_BASEDIR/.git/hooks/post-receive
            chmod +x $_BASEDIR/.git/hooks/*
        fi
    fi
}

_DUCTN_COMMANDS+=("git:configure:server")
--git:configure:server() {
    if [[ -d $_BASEDIR/.git ]]; then
        echo "server update"
        cat $_GITDIR/post-receive >$_BASEDIR/.git/hooks/post-receive
        chmod +x .git/hooks/*
    fi
}