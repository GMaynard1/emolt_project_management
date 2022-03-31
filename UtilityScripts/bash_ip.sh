#!/bin/bash
timedatectl | grep 'Universal time:' | awk '{print $4,$5,$6}' > reboot_info.log
ip -o link show dev enp0s25 | grep -Po 'ether \K[^ ]*' >> reboot_info.log
wget -qO- https://ipecho.net/plain >> reboot_info.log