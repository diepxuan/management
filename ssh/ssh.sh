#!/usr/bin/env bash
cd ~/public_html/code/ssh/

cat config > ~/.ssh/config
find config.d -type f -exec cat {} >> ~/.ssh/config \; -exec printf "\n\n" >> ~/.ssh/config \;

cat ductn > ~/.ssh/ductn
cat ductn.pub > ~/.ssh/ductn.pub

cat dx > ~/.ssh/dx
cat dx.pub > ~/.ssh/dx.pub

cat id_rsa > ~/.ssh/id_rsa
cat id_rsa.pub > ~/.ssh/id_rsa.pub

cat gss > ~/.ssh/gss
cat gss.pub > ~/.ssh/gss.pub
