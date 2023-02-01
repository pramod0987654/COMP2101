#!/bin/bash
echo "FQDN: $(hostname)"
echo "Host Information:"
hostnamectl
echo "IP Address: $(ip addr | grep -w inet | awk '{print$2}' | tail -n 1
)"
df -h /run
