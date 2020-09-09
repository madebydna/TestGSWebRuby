#!/bin/bash

echo 'Adding routes'
sudo /sbin/route del default
sudo /sbin/route add default gw 192.168.111.81
sudo /sbin/route add -net 172.16.0.0 netmask 255.240.0.0 gw 192.168.111.187
sudo /sbin/route add -net 192.168.121.0 netmask 255.255.255.0  gw 192.168.111.187