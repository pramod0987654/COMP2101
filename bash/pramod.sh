#!/bin/bash
host=$(hostname)
osnameandver=$(lsb_release -d |sed 's/Description:*//')
ipaddresses=$(ip addr | grep -w inet | awk '{print $2}' | tail -n 1 | cut -d/ -f1)
rootspace=$( df -h / | awk '{print $4}' | tail -n 1) 
cat<<EOF

Report for $host
=====================
FQDN:$host
Operating System name and version:$osnameandver
IP Address:$ipaddresses
Root Filesystem Free Space: $root
=====================

EOF

