#!/usr/bin/env bash
#!/bin/bash

_DUCTN_COMMANDS+=("ufw:fail2ban:install")
--ufw:fail2ban:install() {
    sudo apt install fail2ban -y --purge --auto-remove
}

_DUCTN_COMMANDS+=("ufw:fail2ban:configuration")
--ufw:fail2ban:configuration() {

    ##########################
    # mysql
    ##########################
    echo "$conf_jail_mysql" | sudo tee /etc/fail2ban/jail.d/mysql.conf

    echo "$conf_filter_mysql_auth" | sudo tee /etc/fail2ban/filter.d/mysql-auth.conf

    ##########################
    # sshd invaliduser
    ##########################
    echo "$conf_jail_sshd_invaliduser" | sudo tee /etc/fail2ban/jail.d/sshd-invaliduser.conf

    echo "$conf_filter_sshd_invaliduser" | sudo tee /etc/fail2ban/filter.d/sshd-invaliduser.conf

    ##########################
    # mssqld invaliduser
    ##########################
    echo $conf_jail_mssql_server | sudo tee /etc/fail2ban/jail.d/mssql-server.conf

    echo $conf_filter_mssql_server | sudo tee /etc/fail2ban/filter.d/mssql-server.conf

    sudo service fail2ban restart
}

conf_jail_mysql="# To log wrong MySQL access attempts add to /etc/my.cnf in [mysqld] or
# equivalent section:
# log-warnings = 2
#
# for syslog (daemon facility)
# [mysqld_safe]
# syslog
#
# for own logfile
# [mysqld]
# log-error=/var/log/mysqld.log
[mysql-auth]
enabled  = true
maxretry = 3
port     = 3306
logpath  = /var/log/syslog
backend  = %(mysql_backend)s"

conf_filter_mysql_auth="# Fail2Ban filter for unsuccesful MySQL authentication attempts
#
#
# To log wrong MySQL access attempts add to /etc/my.cnf in [mysqld]:
# log-error=/var/log/mysqld.log
# log-warnings = 2
#
# If using mysql syslog [mysql_safe] has syslog in /etc/my.cnf

[INCLUDES]

# Read common prefixes. If any customizations available -- read them from
# common.local
before = common.conf

[Definition]

_daemon = mysql

failregex = ^%(__prefix_line)s(?:(?:\d{6}|\d{4}-\d{2}-\d{2})[ T]\s?\d{1,2}:\d{2}:\d{2} )?(?:\d+ )?\[\w+\] (?:\[[^\]]+\] )*Access denied for user '[^']+'@'<HOST>' (to database '[^']*'|\(using password: (YES|NO)\))*\s*$

ignoreregex =

# DEV Notes:
#
# Technically __prefix_line can equate to an empty string hence it can support
# syslog and non-syslog at once.
# Example:
# 130322 11:26:54 [Warning] Access denied for user 'root'@'127.0.0.1' (using password: YES)
#
# Authors: Artur Penttinen
#          Yaroslav O. Halchenko"

conf_jail_sshd_invaliduser="[sshd-invaliduser]
enabled = true
maxretry = 1
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s"

conf_filter_sshd_invaliduser="[INCLUDES]
before = common.conf

[Definition]
_daemon = sshd

failregex = ^%(__prefix_line)s[iI](?:llegal|nvalid) user .*? from <HOST>(?: port \d+)?\s*$
ignoreregex =

[Init]
journalmatch = _SYSTEMD_UNIT=sshd.service + _COMM=sshd"

conf_jail_mssql_server="[mssql-server]
enabled = true
port    = 1433
logpath = /var/opt/mssql/log/errorlog
backend = %(default_backend)s"

conf_filter_mssql_server="# Fail2Ban filter for unsuccesfull MSSQL authentication attempts

[INCLUDES]

# Read common prefixes. If any customizations available -- read them from
# common.local
before = common.conf

[Definition]

_daemon = mssql-server

failregex = ^%(__prefix_line)s.*Login failed for user '[A-Za-z ]*'. Reason: .*provided. \[CLIENT: <HOST>\]

#failregex = ^%(__prefix_line)s.*Login failed for user '[A-Za-z ]*'. Reason: Password did not match that for the login provided. \[CLIENT: <HOST>
#Login failed for user 'sa'. Reason: Password did not match that for the login provided. [CLIENT: <HOST>]*\s*$

ignoreregex ="