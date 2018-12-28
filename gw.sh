#!/usr/bin/env bash

cat > /etc/network/interfaces.d/foxynet << EOF
auto enp0s8
iface enp0s8 inet static
address 192.168.0.1
netmask 255.255.255.0
EOF
ifup enp0s8
/etc/init.d/networking reload

apt-get update
apt-get upgrade -y
apt-get install htop net-tools policykit-1 tor netfilter-persistent isc-dhcp-server -y

systemctl status tor | grep active

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -s 192.168.0.0/24 -j ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
mkdir /etc/iptables/
iptables-save > /etc/iptables/rules.v4

#/etc/default/isc-dhcp-server
dpkg-reconfigure isc-dhcp-server
#/etc/dhcp/dhcpd.conf
systemctl restart isc-dhcp-server
systemctl status isc-dhcp-server | grep active
