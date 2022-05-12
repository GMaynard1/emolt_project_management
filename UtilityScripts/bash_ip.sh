#!/bin/bash
sleep 30 
timedatectl | grep 'Universal time:' | awk '{print $4,$5,$6}' > /home/emolt/reboot_info.log
ip -o link show dev wlan0 | grep -Po 'ether \K[^ ]*' >> /home/emolt/reboot_info.log
ip addr show tun0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 >> /home/emolt/reboot_info.log
wget -qO- https://ipecho.net/plain >> /home/emolt/reboot_info.log
ip addr show tun0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 >> /home/emolt/reboot_info.log
python3 /home/emolt/read.py
bash /home/emolt/insert_reboot.sh
