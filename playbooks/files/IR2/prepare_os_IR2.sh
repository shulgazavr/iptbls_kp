#!/bin/bash

sysctl net.ipv4.conf.all.forwarding=1
echo "net.ipv4.conf.all.forwarding=1" >> /etc/sysctl.conf
yum remove firewalld
yum install iptables iptables-services -y
echo "192.168.0.0/16 via 192.168.255.3" > /etc/sysconfig/network-scripts/route-eth1
echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
echo "GATEWAY=192.168.255.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1

echo "ADD IPTABLES RULES"
iptables -t nat -A PREROUTING -i eth0 -p tcp -m tcp --dport 8080 -j DNAT --to-destination 192.168.0.2:80
iptables -t nat -A POSTROUTING -d 192.168.0.2 -p tcp -m tcp --dport 80 -j SNAT --to-source 192.168.255.2
service iptables save
echo "DONE IPTABLES RULES"

systemctl restart network
systemctl restart network
