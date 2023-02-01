#!/bin/bash/
echo "FQDN: $(hostname)" # to print out the fully qualified domain name (FQDN) of the system where the command is executed
echo "Host Information:"
hostnamectl              #  to  display the current hostname and other system information
echo "IP Address: $(ip addr | grep -w inet | awk '{print$2}' | tail -n 1)"   # 'ip addr'to display all the ip address of the system | grep w inet| to filter the word and display the output starting with word inet   print$2 help to print out the desired line to display as output 
df -h /run               # displays information about the disk space usage of the file system mounted at the /run directory.
