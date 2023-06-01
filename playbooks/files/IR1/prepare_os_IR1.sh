#!/bin/bash

sysctl net.ipv4.conf.all.forwarding=1
echo "net.ipv4.conf.all.forwarding=1" >> /etc/sysctl.conf
sysctl -p
echo "192.168.0.0/16 via 192.168.255.2" > /etc/sysconfig/network-scripts/route-eth1
iptables -t nat -A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE # SNAT --to-source 192.168.255.1
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
iptables -N KNOCKING
iptables -N TARGET1
iptables -N TARGET2
iptables -N TARGET3
iptables -N WELLCOME
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp -i eth0 --dport 22 -j ACCEPT
iptables -A INPUT -j KNOCKING
iptables -A TARGET1 -p tcp --dport 6328 -m recent --name CHECK1 --set -j DROP
iptables -A TARGET1 -j DROP
iptables -A TARGET2 -m recent --name CHECK1 --remove
iptables -A TARGET2 -p tcp --dport 4811 -m recent --name CHECK2 --set -j DROP
iptables -A TARGET2 -j TARGET1
iptables -A TARGET3 -m recent --name CHECK2 --remove
iptables -A TARGET3 -p tcp --dport 15547 -m recent --name CHECK3 --set -j DROP
iptables -A TARGET3 -j TARGET1
iptables -A WELLCOME -m recent --name CHECK3 --remove -p tcp --dport 22 -j ACCEPT
#iptables -A WELLCOME -p tcp --dport 22 -j ACCEPT
iptables -A WELLCOME -j TARGET1
iptables -A KNOCKING -m recent --rcheck --seconds 30 --name CHECK3 -j WELLCOME
iptables -A KNOCKING -m recent --rcheck --seconds 10 --name CHECK2 -j TARGET3
iptables -A KNOCKING -m recent --rcheck --seconds 10 --name CHECK1 -j TARGET2
iptables -A KNOCKING -j TARGET1
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd
