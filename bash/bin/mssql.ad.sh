#!/usr/bin/env bash
#!/bin/bash

--sqlsrv:apt:install() {
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    # sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2019.list)"
    # sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/mssql-server-2019.list)"
    sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2019.list)"
    # sudo apt update
}

--sqlsrv:ad:spn() {
    # From DC

    # Create User
    # Import-Module ActiveDirectory
    # New-ADUser mssql -AccountPassword (Read-Host -AsSecureString "Enter Password") -PasswordNeverExpires $true -Enabled $true
    # Properties -> Accounts -> Account options: -> checked
    # - This account supports Kerberos AES 128 bit encryption
    # - This account supports Kerberos AES 256 bit encryption

    # create SPN
    setspn -A MSSQLSvc/dc3.diepxuan.com:1433 mssql
    setspn -A MSSQLSvc/dx3:1433 mssql

    # From SqlSrv Host
    kinit Administrator@DIEPXUAN.COM
    kvno Administrator@DIEPXUAN.COM
    kvno MSSQLSvc/dx3:1433@DIEPXUAN.COM
    # MSSQLSvc/dx3:1433@DIEPXUAN.COM: kvno = 2

    # From DC
    # Create mssql.keytab
    ktpass /princ MSSQLSvc/dc3.diepxuan.com:1433@DIEPXUAN.COM /ptype KRB5_NT_PRINCIPAL /crypto aes256-sha1 /mapuser mssql@diepxuan.com /out mssql.keytab -setpass -setupn /kvno 2 /pass Ductn@7691
    ktpass /princ MSSQLSvc/dc3.diepxuan.com:1433@DIEPXUAN.COM /ptype KRB5_NT_PRINCIPAL /crypto rc4-hmac-nt /mapuser mssql@diepxuan.com /in mssql.keytab /out mssql.keytab -setpass -setupn /kvno 2 /pass Ductn@7691

    ktpass /princ MSSQLSvc/dx3:1433@DIEPXUAN.COM /ptype KRB5_NT_PRINCIPAL /crypto aes256-sha1 /mapuser mssql@diepxuan.com /in mssql.keytab /out mssql.keytab -setpass -setupn /kvno 2 /pass Ductn@7691
    ktpass /princ MSSQLSvc/dx3:1433@DIEPXUAN.COM /ptype KRB5_NT_PRINCIPAL /crypto rc4-hmac-nt /mapuser mssql@diepxuan.com /in mssql.keytab /out mssql.keytab -setpass -setupn /kvno 2 /pass Ductn@7691

    ktpass /princ mssql@DIEPXUAN.COM /ptype KRB5_NT_PRINCIPAL /crypto aes256-sha1 /mapuser mssql@diepxuan.com /in mssql.keytab /out mssql.keytab -setpass -setupn /kvno 2 /pass Ductn@7691
    ktpass /princ mssql@DIEPXUAN.COM /ptype KRB5_NT_PRINCIPAL /crypto rc4-hmac-nt /mapuser mssql@diepxuan.com /in mssql.keytab /out mssql.keytab -setpass -setupn /kvno 2 /pass Ductn@7691
    # Or from SqlSrv Host
    sudo ktutil
    ktutil: addent -password -p MSSQLSvc/dc3.diepxuan.com:1433@DIEPXUAN.COM -k 2 -e aes256-cts-hmac-sha1-96
    ktutil: addent -password -p MSSQLSvc/dc3.diepxuan.com:1433@DIEPXUAN.COM -k 2 -e rc4-hmac
    ktutil: addent -password -p MSSQLSvc/dx3:1433@DIEPXUAN.COM -k 2 -e aes256-cts-hmac-sha1-96
    ktutil: addent -password -p MSSQLSvc/dx3:1433@DIEPXUAN.COM -k 2 -e rc4-hmac
    ktutil: addent -password -p mssql@DIEPXUAN.COM -k 2 -e aes256-cts-hmac-sha1-96
    ktutil: addent -password -p mssql@DIEPXUAN.COM -k 2 -e rc4-hmac
    ktutil: wkt /var/opt/mssql/secrets/mssql.keytab
    ktutil: quit

    # mssql.keytab
    # Copy to SqlSrv Host under the folder /var/opt/mssql/secrets

    # From SqlSrv Host
    sudo chown mssql:mssql /var/opt/mssql/secrets/mssql.keytab
    sudo chmod 400 /var/opt/mssql/secrets/mssql.keytab
    sudo mssql-conf set network.privilegedadaccount mssql
    sudo /opt/mssql/bin/mssql-conf set network.kerberoskeytabfile /var/opt/mssql/secrets/mssql.keytab
    sudo systemctl restart mssql-server
}
