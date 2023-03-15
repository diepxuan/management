#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("git:configure")
--git:configure() {
    if [[ "$(whoami)" == "ductn" ]]; then
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

        echo "$_gitignore" >~/.gitignore
        chmod 644 ~/.gitignore

        if [[ -d ./.git ]]; then
            # remote repository
            # echo "$_push_to_checkout" >./.git/hooks/push-to-checkout
            # echo "$_pre_commit" >./.git/hooks/pre-commit
            chmod +x ./.git/hooks/*
        fi
    fi
}

_push_to_checkout= <<EOF
#!/bin/sh
set -ex
git read-tree --reset -u HEAD "$1"
EOF

_pre_commit= <<EOF
#!/bin/sh
# echo $(tail -1 version | xargs) | awk -F. -v OFS=. '{$NF += 1 ; print}' >>version
# echo $(tail -1 version | xargs) >version
# git add version
exit 0
EOF

_gitignore= <<EOF
.idea/*
### Node template
# Logs
logs
*.log
npm-debug.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Directory for instrumented libs generated by jscoverage/JSCover
lib-cov

# Coverage directory used by tools like istanbul
coverage

# nyc test coverage
.nyc_output

# Grunt intermediate storage (http://gruntjs.com/creating-plugins#storing-task-files)
.grunt

# node-waf configuration
.lock-wscript

# Compiled binary addons (http://nodejs.org/api/addons.html)
build/Release

# Dependency directories
node_modules
jspm_packages

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

### Example user template template
### Example user template

# IntelliJ project files
.idea
*.iml
out
gen### Go template
# Compiled Object files, Static and Dynamic libs (Shared Objects)
*.o
*.a
*.so

# Folders
_obj
_test

# Architecture specific extensions/prefixes
*.[568vq]
[568vq].out

*.cgo1.go
*.cgo2.c
_cgo_defun.c
_cgo_gotypes.go
_cgo_export.*

_testmain.go

*.exe
*.test
*.prof

# Output of the go coverage tool, specifically when used with LiteIDE
*.out

# external packages folder
vendor/
### GitBook template
# Node rules:
## Grunt intermediate storage (http://gruntjs.com/creating-plugins#storing-task-files)
.grunt

## Dependency directory
## Commenting this out is preferred by some people, see
## https://docs.npmjs.com/misc/faq#should-i-check-my-node_modules-folder-into-git
node_modules

# Book build output
_book

# eBook build output
*.epub
*.mobi
*.pdf
EOF

_DUCTN_COMMANDS+=("git:configure:server")
--git:configure:server() {
    if [[ -d .git ]]; then
        # echo "$_post_receive" >.git/hooks/post-receive
        chmod +x .git/hooks/*
    fi
}
_post_receive= <<EOF
#!/bin/sh
set -ex
git push dx3 -f
EOF
