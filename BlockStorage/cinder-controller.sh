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
# Cinder-Controller
##################################
echo "Cinder Controller!!"
# Cinder CREATE DB
mysql -e "CREATE DATABASE cinder;"
mysql -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '${STACK_PASSWD}';"
mysql -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '${STACK_PASSWD}';"
mysql -e "FLUSH PRIVILEGES;"

# Cinder CREATE SERVICE
. ../admin-openrc
openstack user create --domain default --password ${STACK_PASSWD} cinder
openstack role add --project service --user cinder admin
openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3

# Create the Block Storage service API endpoints
. ../admin-openrc
openstack endpoint create --region RegionOne volumev3 public http://${SET_IP}:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 internal http://${SET_IP}:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 admin http://${SET_IP}:8776/v3/%\(project_id\)s

# Install the Cinder packages
sudo apt install -y cinder-api cinder-scheduler python3-cinderclient

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
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp
#crudini --set /etc/cinder/cinder.conf DEFAULT iscsi_helper tgtadm

# Cinder Reg. DB
su -s /bin/sh -c "cinder-manage db sync" cinder

# Configure Compute to use Block Storage
crudini --set /etc/nova/nova.conf cinder os_region_name RegionOne

# Cinder Verify operation
service nova-api restart
service cinder-scheduler restart
service apache2 restart

#echo 'include /var/lib/cinder/volumes/*' >> /etc/tgt/conf.d/cinder.conf
echo "CINDER CONTROLLER INSTALLED ... END"


