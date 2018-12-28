#!/usr/bin/env bash

cat > /etc/network/interfaces.d/foxynet << EOF
auto enp0s8
iface enp0s8 inet static
address 192.168.0.1
netmask 255.255.255.0
EOF
ifup enp0s8
/etc/init.d/networking restart

apt-get update
apt-get upgrade -y
apt-get install htop net-tools policykit-1 tor isc-dhcp-server -y
#netfilter-persistent

cat >> /etc/tor/torrc << EOF
DNSPort 192.168.0.1:53
EOF
/etc/init.d/tor restart

#iptables -P INPUT DROP
#iptables -P FORWARD DROP
#iptables -A INPUT -i lo -j ACCEPT
#iptables -A INPUT -s 192.168.0.0/24 -j ACCEPT
#iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
#/etc/init.d/netfilter-persistent save
#/etc/init.d/netfilter-persistent restart

dpkg-reconfigure isc-dhcp-server
#/etc/dhcp/dhcpd.conf
#subnet 192.168.0.0 netmask 255.255.255.0 {
#  option domain-name-servers 192.168.0.1;
#  option domain-name "example.net";
#  option routers 192.168.0.1;
#}
/etc/init.d/isc-dhcp-server restart
