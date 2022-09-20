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
read -p "Do you Run fdisk? ?? {yen|no|ENTER=no} :" CHECKER_fdisk
if [ "$CHECKER_fdisk" = "yes" ]; then
    echo "good !!"
    read -p "Inpute the X ?? {b|c|ENTER=b} :" CHECKER_SDX
    lsblk
    partprobe -s
    partprobe /dev/sd${CHECKER_SDX}1
else
    echo "---please check the your disk---"
    echo "fdisk /dev/sdb"
    echo "> n > p > 1 > enter > 최대m"
    echo "> t > 8e > w"
    echo "lsblk"
    exit 100
fi

##################################
# Storage node
##################################
echo "[Prerequisites]"

apt install lvm2 thin-provisioning-tools

pvcreate /dev/sd${CHECKER_SDX}1
pvdisplay

vgcreate cinder-volumes /dev/sd${CHECKER_SDX}1
vgdisplay
