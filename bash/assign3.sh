#/bin/bash

# Check if LXD is installed, if not, install it
if ! dpkg-query -W lxd >/dev/null 2>&1
then
	echo "installing LXD"
	sudo snap install lxd 
fi

# Check if lxdbr0 interface exists, if it doesnot,you can run lxd init
if ! ip a show lxdbr0 &> /dev/null
then
	echo "updating the ip address"
    	sudo lxd init --auto
fi

# Check if container exists, if not, launch it
if ! lxc list --format csv | grep -q COMP2101-S22
then
	echo "launching a new container"
    	lxc launch ubuntu:20.04 COMP2101-S22
fi

if [ "$(grep -c 'COMP2101-S22' /etc/hosts)" -eq 0 ]; then
    	container_ip=$(lxc list | awk '/COMP2101-S22/{print $6}')
    	echo "$container_ip COMP2101-S22" | sudo tee -a /etc/hosts > /dev/null
else
    	container_ip=$(lxc list | awk '/COMP2101-S22/{print $6}')
    	sudo sed -i "s/.*COMP2101-S22.*/$container_ip COMP2101-S22/" /etc/hosts
fi

# Install Apache2 in the container if necessary
if ! lxc exec COMP2101-S22 -- which apache2 &> /dev/null 2>&1
then
	echo "installing Apache2 server"
   	sudo lxc exec COMP2101-S22 -- apt-get install -y apache2 >/dev/null 2>&1
fi
sudo apt install curl >/dev/null
# Retrieve the default web page from the container's web service with curl
if curl http://COMP2101-S22 >/dev/null 2>&1
then
	echo "Success: It was successful" 
else
	echo "Error: Some error occured"
fi
