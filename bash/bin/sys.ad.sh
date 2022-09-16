#!/usr/bin/env bash
#!/bin/bash

--sys:ad:install() {
    sudo apt install -y realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit

    realm discover diepxuan.com
    # Join Domain
    --sys:ad:krb5conf
    sudo realm join -U Administrator diepxuan.com

    # Domain User Config
    --sys:ad:mkhomedir
    --sys:ad:sssd
    sudo systemctl restart sssd

    # Domain User Login
    --sys:ad:sudoers
    --sys:ad:sshd
}

--sys:ad:krb5conf() {
    --force() {
        sudo rm -rf /etc/krb5.conf
    }

    $@
    if [[ -f /etc/krb5.conf ]]; then
        sudo sed -i 's/.*rdns.*/rdns = false/' /etc/krb5.conf
    else
        echo "[logging]
default = FILE:/var/log/krb5libs.log
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmind.log

[libdefaults]
udp_preference_limit = 0
dns_lookup_realm = true
dns_lookup_kdc = true
ticket_lifetime = 24h
renew_lifetime = 7d
forwardable = true
rdns = false
default_realm = DIEPXUAN.COM
default_ccache_name = KEYRING:persistent:%{uid}
# default_ccache_name = FILE:/tmp/krb5cc_%{uid}

[realms]
DIEPXUAN.COM = {
    kdc = DC.DIEPXUAN.COM:88
    admin_server = DC.DIEPXUAN.COM
    default_domain = DIEPXUAN.COM
}

[domain_realm]
diepxuan.com = DIEPXUAN.COM
.diepxuan.com = DIEPXUAN.COM
" | sudo tee /etc/krb5.conf >/dev/null
    fi
}

--sys:ad:mkhomedir() {
    echo "Name: Create home directory on login
Default: yes
Priority: 900
Session-Type: Additional
Session:
        optional                        pam_mkhomedir.so skel=/etc/skel umask=077" | sudo tee /usr/share/pam-configs/mkhomedir >/dev/null
    sudo pam-auth-update --enable mkhomedir
}

--sys:ad:sssd() {
    # access_provider = ad
    sudo sed -i 's/.*use_fully_qualified_names.*/use_fully_qualified_names = True/' /etc/sssd/sssd.conf
    sudo sed -i 's/.*fallback_homedir.*/fallback_homedir = \/home\/%d\/%u/' /etc/sssd/sssd.conf
    sudo systemctl restart sssd
}

--sys:ad:sudoers() {
    sudo realm permit 'Domain Users' 'Users'
    if [ "$(whoami)" = "ductn" ]; then
        echo "
%quantri@diepxuan.com           ALL=(ALL) NOPASSWD:ALL
%Domain\ Admins@diepxuan.com    ALL=(ALL) NOPASSWD:ALL

%DIEPXUAN.COM\\Domain\ Admins   ALL=(ALL) NOPASSWD:ALL
%DIEPXUAN.COM\\Quantri          ALL=(ALL) NOPASSWD:ALL

%Domain\ Admins                 ALL=(ALL) NOPASSWD:ALL
%Quantri                        ALL=(ALL) NOPASSWD:ALL
" | sudo tee /etc/sudoers.d/91-domain-admins >/dev/null
    fi

}

--sys:ad:sshd() {
    # /etc/ssh/sshd_config.d/
    echo "# Settings that override the global settings for matching groups only
# AllowGroups diepxuan.com\Quantri
Match Group Quantri
    PasswordAuthentication yes
" | sudo tee /etc/ssh/sshd_config.d/91-domain-admins.conf >/dev/null
    sudo sed -i 's/.*PubkeyAuthentication/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sudo sed -i 's/.*PasswordAuthentication/PasswordAuthentication no/' /etc/ssh/sshd_config

    sudo sed -i 's/.*UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

    sudo sed -i 's/.*ChallengeResponseAuthentication\ yes/ChallengeResponseAuthentication\ no/' /etc/ssh/sshd_config
    sudo sed -i 's/.*GSSAPIAuthentication.*/#GSSAPIAuthenticationc no/' /etc/ssh/sshd_config
    sudo sed -i 's/.*GSSAPICleanupCredentials.*/#GSSAPICleanupCredentials yes/' /etc/ssh/sshd_config

    sudo sed -i 's/.*KerberosAuthentication.*/#KerberosAuthentication yes/' /etc/ssh/sshd_config
    sudo sed -i 's/.*KerberosOrLocalPasswd.*/#KerberosOrLocalPasswd yes/' /etc/ssh/sshd_config

    sudo service sshd restart
}
