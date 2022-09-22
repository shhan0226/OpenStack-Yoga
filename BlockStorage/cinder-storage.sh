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
source ../set.conf
echo "... set!!"

##################################
# Format Disk
##################################
apt install lvm2 thin-provisioning-tools
fdisk -l

read -p "Do you Run fdisk? ?? {yes|no|ENTER=no} :" CHECKER_fdisk
if [ "$CHECKER_fdisk" = "yes" ]; then
    echo "good !!"    
    read -p "Inpute the X(sdX) ?? {b|c|ENTER=b} :" CHECKER_SDX
    lsblk
    partprobe -s
    partprobe /dev/sd${CHECKER_SDX}1 
    lsblk   
else
    echo " "
    echo "---please check the fdisk---"
    echo "fdisk /dev/sdX"
    echo "> n > p > 1 > enter > 최대m"
    echo "> t > 8e > w"
    echo " "
    echo "lsblk"
    echo "---creative LVM---"
    echo "pvcreate /dev/sdX1"
    echo "pvdisplay"
    echo "vgcreate cinder-volumes /dev/sdX1"
    echo "vgdisplay"
    echo " "
    echo "---configure LVM---"
    echo "vim /etc/lvm/lvm.conf"
    echo ">"
    echo "devices {"
    echo "        filter = [ \"a/sdX1/\", \"r/.*/\"] "
    exit 100
fi

##################################
# Cinder-Storage
##################################
echo "Cinder Storage!!"
apt install -y cinder-volume tgt
crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:${STACK_PASSWD}@${SET_IP}/cinder
crudini --set /etc/cinder/cinder.conf DEFAULT transport_url rabbit://openstack:${STACK_PASSWD}@${SET_IP}
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://${SET_IP}:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://${SET_IP}:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers ${SET_IP}:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password ${STACK_PASSWD}
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip ${SET_IP}
crudini --set /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set /etc/cinder/cinder.conf lvm volume_group cinder-volumes
crudini --set /etc/cinder/cinder.conf lvm target_protocol iscsi
crudini --set /etc/cinder/cinder.conf lvm target_helper tgtadm
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends lvm 
crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers http://${SET_IP}:9292
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp
service tgt restart
service cinder-volume restart

##################
# backup service
##################
apt install cinder-backup
crudini --set /etc/cinder/cinder.conf DEFAULT backup_driver cinder.backup.drivers.swift.SwiftBackupDriver
crudini --set /etc/cinder/cinder.conf DEFAULT backup_swift_url ${SET_IP}
# openstack catalog show object-store
service cinder-backup restart

##################
# Verify Cinder operation
##################
systemctl restart iscsid
lsblk
# openstack volume service list