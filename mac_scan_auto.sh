#!/bin/bash

PATH=/home/pi/bash/scripts:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
 
# Author: 
# Date Created: 
# Date Modified: 
# Description: 
# Usage: 

echo "<<---AUTOMATIC SCAN--->>" >>/home/pi/mac_scan.log
TZ='America/Los_Angeles' date >>/home/pi/mac_scan.log
nmap -sn 192.168.0.0/24 | grep "MAC" | awk '{print $3}'| sort > /home/pi/arp.txt

readarray -t mac </home/pi/arp.txt

foundall=true

for address in "${mac[@]}"; do
    if ! grep -Fxq "$address" /home/pi/arp_table.txt;
    then
        echo "WARNING: $address is an unknown device on the network" >> /home/pi/mac_scan.log
	nmap -sn 192.168.0.0/24 | grep -B 2 "$address" | tee -a /home/pi/mac_scan.log | mutt -s "Unknown Devices on Network" chris1calvert@gmail.com
	echo ""	
	echo "MAC SEARCH RESULTS: $address" >> /home/pi/mac_scan.log
	nmap -sn 192.168.0.0/24 | grep -B 2 "$address" > /home/pi/tmpmac.txt
	cat /home/pi/tmpmac.txt | grep "Nmap" | awk {'print $5'} > /home/pi/tmpip.txt
	unknown_mac=$( cat /home/pi/tmpip.txt )
	nmap -O $unknown_mac | tee -a /home/pi/mac_scan.log | mutt -s "OS Scan for $address" chris1calvert@gmail.com
	foundall=false	
    fi
done 

[[ "${foundall}" == 'true' ]] && echo "All Devices are familiar on your network" | tee -a /home/pi/mac_scan.log


#       nmap -sn 192.168.0.0/24 | grep -B 2 "$address" >> /home/pi/mac_scan.log
