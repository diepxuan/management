############ network ############

sudo nano /etc/network/interfaces
##########
<<EOF
auto vmbr1
iface vmbr1 inet manual
    address 10.0.1.1/24
    bridge_ports none
    bridge_stp off
    bridge_fd 0
    post-up echo 1 >/proc/sys/net/ipv4/ip_forward
    post-up iptables -t nat -A POSTROUTING -s '10.0.1.0/24' -o vmbr0 -j MASQUERADE
    post-down iptables -t nat -D POSTROUTING -s '10.0.1.0/24' -o vmbr0 -j MASQUERADE
    post-up iptables -t raw -I PREROUTING -i fwbr+ -j CT --zone 1
    post-down iptables -t raw -D PREROUTING -i fwbr+ -j CT --zone 1
EOF
sudo ifup vmbr1

sudo nano /etc/network/interfaces.d/ifcnf
##########
# Fix FW block VM
post-up iptables -t raw -I PREROUTING -i fwbr+ -j CT --zone 1
post-down iptables -t raw -D PREROUTING -i fwbr+ -j CT --zone 1

post-up iptables -t nat -A PREROUTING -p tcp -m tcp --dport 0:8005 -j DNAT --to-destination 10.0.1.10:0-8005
post-down iptables -t nat -D PREROUTING -p tcp -m tcp --dport 0:8005 -j DNAT --to-destination 10.0.1.10:0-8005

# HTTP
post-up iptables -t nat -A PREROUTING -i vmbr0 -p tcp --dport 80 -j DNAT --to 192.168.0.2:80
post-down iptables -t nat -D PREROUTING -i vmbr0 -p tcp --dport 80 -j DNAT --to 192.168.0.2:80

# HTTPS
post-up iptables -t nat -A PREROUTING -i vmbr0 -p tcp --dport 443 -j DNAT --to 192.168.0.2:443
post-down iptables -t nat -D PREROUTING -i vmbr0 -p tcp --dport 443 -j DNAT --to 192.168.0.2:443

# PLEX
post-up iptables -t nat -A PREROUTING -i vmbr0 -p tcp --dport 32400 -j DNAT --to 192.168.0.2:32400
post-down iptables -t nat -D PREROUTING -i vmbr0 -p tcp --dport 32400 -j DNAT --to 192.168.0.2:32400

############### dnsmasq ###########
sudo apt install dnsmasq dnsutils -y

sudo nano /etc/dnsmasq.conf

<<EOF
domain=diepxuan.com
EOF

#Around line 106
interface=vmbr1
# Or which to listen on by address (remember to include 127.0.0.1 if you use this.)
#listen-address=

#around line 159
dhcp-range=10.0.1.100,10.0.1.150,12h

#around line 337
dhcp-option=vmbr1,3,192.168.50.1
#dhcp-option=eth0,3,192.168.50.1

#line 66
# You can use Google's open DNS servers
server=1.1.1.1
server=8.8.8.8

dhcp-leasefile=/var/lib/misc/dnsmasq.leases

sudo dnsmasq --test

sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq

#You should be able to restart networking service without any failures
#sudo systemctl restart networking

sudo nano /etc/dnsmasq.conf
dhcp-host=BA:1F:4A:6A:63:A1,dc1,10.0.1.10,infinite
dhcp-host=62:F0:9D:12:02:61,dc2,10.0.2.10,infinite
dhcp-host=1E:7B:8C:71:F0:91,sql1,10.0.1.11,infinite
sudo systemctl restart dnsmasq
