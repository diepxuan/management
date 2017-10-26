#!/usr/bin/env bash
cat my.ini > /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart
