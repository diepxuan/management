#!/usr/bin/env bash

# global gitignore
cat ~/public_html/code/bash/git/.gitignore > ~/.gitignore
git config --global core.excludesfile ~/.gitignore

# setting
git config --global user.name "Trần Ngọc Đức"
git config --global user.email "caothu91@gmail.com"

# push
git config --global push.default simple

# file mode
git config --global core.fileMode false

# line endings
git config --global core.autocrlf false
git config --global core.eol lf

# Cleanup
git config --global gc.auto 0
