#!/bin/bash

sysctl net.ipv4.conf.all.forwarding=1
echo "net.ipv4.conf.all.forwarding=1" >> /etc/sysctl.conf
sysctl -p
echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
echo "GATEWAY=192.168.255.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
yum install iptables iptables-services nmap -y
systemctl restart network
systemctl restart network

