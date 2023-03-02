#!/bin/bash
#
# this script displays some host identification information for a Linux machine
#
# Sample output:
#   Hostname      : zubu
#   LAN Address   : 192.168.2.2
#   LAN Name      : net2-linux
#   External IP   : 1.2.3.4
#   External Name : some.name.from.our.isp

# TASK 1: Accept options on the command line for verbose mode and an interface name - must use the while loop and case command as shown in the lesson - getopts not acceptable for this task
#         If the user includes the option -v on the command line, set the variable $verbose to contain the string "yes"
#            e.g. network-config-expanded.sh -v
#         If the user includes one and only one string on the command line without any option letter in front of it, only show information for that interface
#            e.g. network-config-expanded.sh ens34
#         Your script must allow the user to specify both verbose mode and an interface name if they want
# TASK 2: Dynamically identify the list of interface names for the computer running the script, and use a for loop to generate the report for every interface except loopback - do not include loopback network information in your output

################
# Data Gathering
################
# the first part is run once to get information about the host
# grep is used to filter ip command output so we don't have extra junk in our output
# stream editing with sed and awk are used to extract only the data we want displayed

# Task 1 - Accept command line options for verbose mode and interface name
verbose="no"
interface=""

while [ $# -gt 0 ]; do
  case "$1" in
    -v)
      verbose="yes"
      ;;
    *)
      if [[ "$interface" == "" ]]; then
        interface=$1
      else
        echo "Error: Too many arguments."
        exit 1
      fi
      ;;
  esac
  shift
done

#####
# Once per host report
#####
[ "$verbose" = "yes" ] && echo "Gathering host information"
# we use the hostname command to get our system name and main ip address
my_hostname="$(hostname) / $(hostname -I)"

[ "$verbose" = "yes" ] && echo "Identifying default route"
# the default route can be found in the route table normally
# the router name is obtained with getent
default_router_address=$(ip r s default| awk '{print $3}')
default_router_name=$(getent hosts $default_router_address|awk '{print $2}')

[ "$verbose" = "yes" ] && echo "Checking for external IP address and hostname"
# finding external information relies on curl being installed and relies on live internet connection
external_address=$(curl -s icanhazip.com)
external_name=$(getent hosts $external_address | awk '{print $2}')

cat <<EOF

System Identification Summary
=============================
Hostname      : $my_hostname
Default Router: $default_router_address
Router Name   : $default_router_name
External IP   : $external_address
External Name : $external_name

EOF

#####
# End of Once per host report

# set verbose mode to "no" by default
verbose="no"

# use ip command to get list of interfaces and extract interface names
interfaces=$(ip link show | awk -F': ' '{print $2}' | grep -v '^lo$')

# iterate through each interface and generate per-interface report
for interface in $interfaces; do
    [ "$verbose" = "yes" ] && echo "Reporting on interface: $interface"

    [ "$verbose" = "yes" ] && echo "Getting IPV4 address and name for interface $interface"
    ipv4_address=$(ip a s $interface|awk -F '[/ ]+' '/inet /{print $3}')
    ipv4_hostname=$(getent hosts $ipv4_address | awk '{print $2}')

    [ "$verbose" = "yes" ] && echo "Getting IPV4 network block info and name for interface $interface"
    network_address=$(ip route list dev $interface scope link|cut -d ' ' -f 1)
    network_number=$(cut -d / -f 1 <<<"$network_address")
    network_name=$(getent networks $network_number|awk '{print $1}')

    cat <<EOF

Interface $interface:
===============
Address         : $ipv4_address
Name            : $ipv4_hostname
Network Address : $network_address
Network Name    : $network_name

EOF
done
