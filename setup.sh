#!/usr/bin/env bash
# cat ~/public_html/code/setup/ubuntu/.bashrc > ~/.bashrc
# source ~/.bashrc

cd ~/public_html/code/setup/git/
bash ./git.sh

cd ~/public_html/code/httpd/
bash ./httpd.sh

cd ~/public_html/code/mysql/
bash ./mysql.sh

cd ~/public_html/code/php/phpmyadmin/
bash ./phpmyadmin.sh
