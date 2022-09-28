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
    read -p "Inpute the sdX ?? {sdb|sdc|ENTER=sdd} :" SDX_
    SDX_=${SDX_:-sdd}
    echo ${SDX_}
    lsblk
    # creative LVM
    pvcreate /dev/${SDX_}1
    pvdisplay
    vgcreate cinder-volumes /dev/${SDX_}1
    vgdisplay
    partprobe -s
    partprobe /dev/${SDX_}1    
    lsblk    
else
    echo " "
    echo "###################################################"
    echo "---please check the fdisk---"
    echo "lsblk"
    echo "fdisk /dev/sdX"
    echo "> n > p > 1 > enter > 최대m"
    echo "> t > 8e > w"
    echo " "        
    echo "---configure LVM---"
    echo "vim /etc/lvm/lvm.conf"
    echo ">"
    echo "devices {"
    echo "        filter = [ \"a/sdX1/\", \"r/.*/\"] "
    echo "###################################################"
    echo " "
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
crudini --set /etc/cinder/cinder.conf DEFAULT backup_swift_url http://${SET_IP}:8080/v1
# openstack catalog show object-store
service cinder-backup restart

##################
# Verify Cinder operation
##################
systemctl restart iscsid
service cinder-backup restart
service cinder-volume restart
lsblk
# openstack volume service list
echo "CINDER STORAGE INSTALLED ... END"
