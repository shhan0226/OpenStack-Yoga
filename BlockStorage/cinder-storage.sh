#!/bin/bash

##################################
# Change root privileges.
##################################
IAMACCOUNT=$(whoami)
echo "${IAMACCOUNT}"
if [ "$IAMACCOUNT" = "root" ]; then
    echo "It's root account."
else
    echo "It's not a root account."
	exit 100
fi

##################################
# auth
##################################
. admin-openrc
echo "$CONTROLLER_HOST"
echo "$SET_IP"
echo "$SET_IP2"
echo "$SET_IP_ALLOW"
echo "$INTERFACE_NAME_"
echo "$STACK_PASSWD"
echo "$CPU_ARCH"
echo "... set!!"



##################################
# Cinder-Storage
##################################
echo "Cinder Storage !!"

fdisk -l
read -p "Do you fix /dev/sdX?? {yen|no|ENTER=yes} :" CHECKER_SD
if [ "$CHECKER_SD" = "yes" ]; then
    echo "good!"
else
    echo "fdisk /dev/${CHECKER_SD}"
    echo "> n > p > 1 > enter > 최대m"
    echo "> t > 8e > w"
    echo "lsblk"
    exit 100
fi

partprobe -s
partprobe /dev/sdb1


##################################
# Storage node
##################################
echo "[Prerequisites]"

apt install lvm2 thin-provisioning-tools
