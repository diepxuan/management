#!/usr/bin/env bash
#!/bin/bash

#sudo apt install -y unixodbc tdsodbc php?.?-sybase &>/dev/null
#sudo phpenmod sybase

_DUCTN_COMMANDS+=("sqlsrv:php:install")
--sqlsrv:php:install() {
    # Install PHP and other required packages
    #########################################
    ductn php:apt:install
    sudo apt install -y php-dev php-xml -y

    # Install the ODBC Driver and SQL Command Line Utility for SQL Server
    #####################################################################
    ductn sqlsrv:apt:install

    # curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    # # curl https://packages.microsoft.com/config/ubuntu/19.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
    # curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
    # sudo apt update

    sudo ACCEPT_EULA=Y apt install msodbcsql17 mssql-tools locales unixodbc-dev -y
    # sudo ACCEPT_EULA=Y apt install unixodbc-dev -y
    sudo locale-gen en_US.utf8
    sudo update-locale
    #sqlcmd -S localhost -U sa -P yourpassword -Q "SELECT @@VERSION"
    #echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
    #source ~/.bashrc

    # Install the PHP Driver for SQL Server
    #######################################
    # sudo apt install php-pear gcc g++ make autoconf libc-dev pkg-config libxml2-dev -y
    sudo apt install php-pear -y
    sudo pecl channel-update pecl.php.net
    sudo pecl install sqlsrv pdo_sqlsrv
    # sudo pecl install sqlsrv-5.7.0preview pdo_sqlsrv-5.7.0preview
}

_DUCTN_COMMANDS+=("sqlsrv:php:enable")
--sqlsrv:php:enable() {
    --sqlsrv:php:disable
    # printf "priority=20\nextension=sqlsrv.so\n" | sudo tee /etc/php/5.6/mods-available/sqlsrv.ini
    # printf "priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee /etc/php/5.6/mods-available/pdo_sqlsrv.ini

    # printf "priority=20\nextension=sqlsrv.so\n" | sudo tee /etc/php/7.0/mods-available/sqlsrv.ini
    # printf "priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee /etc/php/7.0/mods-available/pdo_sqlsrv.ini

    # printf "priority=20\nextension=sqlsrv.so\n" | sudo tee /etc/php/7.1/mods-available/sqlsrv.ini
    # printf "priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee /etc/php/7.1/mods-available/pdo_sqlsrv.ini

    # printf "priority=20\nextension=sqlsrv.so\n" | sudo tee /etc/php/7.2/mods-available/sqlsrv.ini
    # printf "priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee /etc/php/7.2/mods-available/pdo_sqlsrv.ini

    # printf "priority=20\nextension=sqlsrv.so\n" | sudo tee /etc/php/7.3/mods-available/sqlsrv.ini
    # printf "priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee /etc/php/7.3/mods-available/pdo_sqlsrv.ini

    # printf "priority=20\nextension=sqlsrv.so\n" | sudo tee /etc/php/7.4/mods-available/sqlsrv.ini
    # printf "priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee /etc/php/7.4/mods-available/pdo_sqlsrv.ini

    # printf "; priority=20\nextension=sqlsrv.so\n" | sudo tee /etc/php/8.0/mods-available/sqlsrv.ini
    # printf "; priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee /etc/php/8.0/mods-available/pdo_sqlsrv.ini
    $(php --ini | grep "Configuration File (php.ini)" | sed -e "s|.*:\s*||" -e "s/\/cli$//")
    printf "priority=20\nextension=sqlsrv.so\n" | sudo tee $(php --ini | grep "Configuration File (php.ini)" | sed -e "s|.*:\s*||" -e "s/\/cli$//")/mods-available/sqlsrv.ini
    printf "priority=30\nextension=pdo_sqlsrv.so\n" | sudo tee $(php --ini | grep "Configuration File (php.ini)" | sed -e "s|.*:\s*||" -e "s/\/cli$//")/mods-available/pdo_sqlsrv.ini

    # sudo phpenmod -v 8.0 sqlsrv pdo_sqlsrv
    sudo phpenmod sqlsrv pdo_sqlsrv

    #echo extension=sqlsrv.so | sudo tee -a `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/20-sqlsrv.ini
    #echo extension=pdo_sqlsrv.so | sudo tee -a `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini
}

_DUCTN_COMMANDS+=("sqlsrv:php:disable")
--sqlsrv:php:disable() {
    sudo phpdismod sqlsrv pdo_sqlsrv
    sudo /usr/sbin/service apache2 restart
}

_DUCTN_COMMANDS+=("mssql:php:install")
--mssql:php:install() {
    --sqlsrv:php:install
}

_DUCTN_COMMANDS+=("mssql:php:enable")
--mssql:php:enable() {
    --sqlsrv:php:enable
    sudo /usr/sbin/service apache2 start
}

_DUCTN_COMMANDS+=("mssql:php:disable")
--mssql:php:disable() {
    --sqlsrv:php:disable
}