#!/bin/bash

NS1=false
NS2=false
# DEV=0

--dns:init() {
    if [[ -z ${NS1+x} ]]; then return; else
        NS1="$(--host:address dc1.diepxuan.com)"
        if [[ ! $NS1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            NS1=192.168.11.9
            exit 1
        fi
    fi
    if [[ -z ${NS1+x} ]]; then return; else
        NS2="$(--host:address dc2.diepxuan.com)"
        if [[ ! $NS2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            NS2=192.168.11.9
            exit 1
        fi
    fi
}

--dns:update() {
    --force() {
        DEV=1
    }
    $@
    --dns:init
    --dns:_update
}

--dns:_update() {
    if [[ -f /var/cache/bind/ns1.diepxuan.com ]] && [[ -f /var/cache/bind/ns2.diepxuan.com ]]; then
        if [[ "$NS1" =~ $(</var/cache/bind/ns1.diepxuan.com) ]] && [[ "$NS2" =~ $(</var/cache/bind/ns2.diepxuan.com) ]]; then
            if [[ $DEV -eq 0 ]]; then
                return 0
            fi
        else
            echo "$NS1" | sudo tee /var/cache/bind/ns1.diepxuan.com >/dev/null
            echo "$NS2" | sudo tee /var/cache/bind/ns2.diepxuan.com >/dev/null
        fi
    fi

    --dns:update:nameservers
    --dns:update:options
    --dns:update:named

    sudo systemd-resolve --flush-caches
    # sudo rndc flush
    # sudo rndc reload
    sudo rndc reconfig
    sudo service named restart
}

--dns:uninstall() {
    sudo netplan set ethernets.ens192=
    sudo netplan apply
    sudo apt remove bind9 bind9utils bind9-doc -y
}

--dns:update:nameservers() {
    if [[ -f /etc/resolvconf/resolv.conf.d/base ]]; then
        echo "nameserver "$NS1"" | sudo tee /etc/resolvconf/resolv.conf.d/base >/dev/null
    fi
    # sudo netplan set ethernets.ens192.nameservers.addresses=[127.0.0.1,1.1.1.1,8.8.8.8]
    # sudo netplan set ethernets.ens192.nameservers.search=["diepxuan.com","diepxuan.site"]
    sudo netplan apply
}

--dns:update:named() {
    echo "zone \"diepxuan.site\" {
    type slave;
    file \"/var/cache/bind/db.diepxuan.site\";
    notify yes;
    allow-update {
        "$NS1";
        "$NS2";
    };
    allow-transfer {
        "$NS1";
        "$NS2";
    };
};
zone \"diepxuan.com\" {
    type slave;
    file \"/var/cache/bind/db.diepxuan.com\";
    notify yes;
    allow-update {
        "$NS1";
        "$NS2";
    };
    allow-transfer {
        "$NS1";
        "$NS2";
    };
};" | sudo tee /etc/bind/named.conf.local >/dev/null
    echo "" | sudo tee /etc/bind/named.conf.local >/dev/null
}

--dns:update:tsl() {
    if [[ -f /etc/letsencrypt/live/diepxuan.com/privkey.pem ]]; then
        sudo mkdir -p /etc/bind/ssl/diepxuan.com
        sudo cp /etc/letsencrypt/live/diepxuan.com/privkey.pem /etc/bind/ssl/diepxuan.com/privkey.pem
        sudo cp /etc/letsencrypt/live/diepxuan.com/fullchain.pem /etc/bind/ssl/diepxuan.com/fullchain.pem
        sudo chmod 755 /etc/bind/ssl/diepxuan.com
        sudo chmod -R 644 /etc/bind/ssl/diepxuan.com/*
    fi
}

--dns:update:options() {
    --dns:update:tsl
    echo "# tls local-tls {
#    key-file \"/etc/bind/ssl/diepxuan.com/privkey.pem\";
#    cert-file \"/etc/bind/ssl/diepxuan.com/fullchain.pem\";
# };
options {
    directory \"/var/cache/bind\";
    forwarders {
        # 94.140.14.14;
        # 94.140.15.15;
        "$NS1";
        "$NS2";
        1.1.1.1;
        8.8.8.8;
    };
    forward only;
    dnssec-validation auto;

    allow-recursion { any; };
    recursion yes;

    auth-nxdomain no;
    allow-transfer {
        "$NS1";
        "$NS2";
    };

    listen-on-v6 {any;};
    # listen-on port 8443 tls local-tls http default {any;};
    # listen-on-v6 port 8443 tls local-tls http default {any;};

    masterfile-format text;
    also-notify {
        "$NS1";
        "$NS2";
    };
};" | sudo tee /etc/bind/named.conf.options >/dev/null
}

--dns:server:install() {
    #!/bin/bash
    cd "$(dirname "$0")"

    # sudo apt install bind9 bind9utils bind9-doc dnsutils -y

    # cat dns/slave.conf.options | ssh dx1.diepxuan.com "sudo tee /etc/bind/named.conf.options"
    # cat dns/slave.conf.local | ssh dx1.diepxuan.com "sudo tee /etc/bind/named.conf.local"
    # scp dns/db.* ductn@dx1.diepxuan.com
    # ssh dx1.diepxuan.com "
    #         mkdir /etc/bind/zones
    #         sudo mv db.* /etc/bind/zones
    #         sudo service bind9 restart
    #     "

    # cat dns/master.conf.options | ssh dx3.diepxuan.com "sudo tee /etc/bind/named.conf.options"
    # cat dns/master.conf.local | ssh dx3.diepxuan.com "sudo tee /etc/bind/named.conf.local"
    # scp dns/db.* ductn@dx3.diepxuan.com:~/
    # ssh dx3.diepxuan.com "
    #         mkdir -p /etc/bind/zones
    #         sudo mv ~/db.* /etc/bind/zones
    #         sudo service bind9 restart
    #     "

    # sudo apt install stunnel4 -y --purge --auto-remove
    # cat /var/www/base/bash/dns/stunnel.conf | sudo tee /etc/stunnel/stunnel.conf
    # sudo service bind9 restart

    # sudo nano /etc/apparmor.d/local/usr.sbin.named
    # add line:
    # /etc/letsencrypt/** r,
    #
    # sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.named
    # sudo service apparmor restart
    #
    # sudo chmod 750 /etc/letsencrypt/live/
    # sudo chmod 750 /etc/letsencrypt/archive/
    # sudo chgrp bind /etc/letsencrypt/live/diepxuan.com/privkey.pem
    # sudo chmod 0640 /etc/letsencrypt/live/diepxuan.com/privkey.pem
}