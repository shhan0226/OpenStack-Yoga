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
# Glance
##################################
echo "Glance !!"

echo "[Prerequisites]"


echo "Glance CREATE DB ..."
mysql -e "CREATE DATABASE glance;"
mysql -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '${STACK_PASSWD}';"
mysql -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '${STACK_PASSWD}';"
mysql -e "FLUSH PRIVILEGES;"


echo "Glance CREATE SERVICE ..."
. admin-openrc
openstack user create --domain default --password ${STACK_PASSWD} glance
openstack role add --project service --user glance admin

openstack service create --name glance \
  --description "OpenStack Image" image


echo "Glance - Create the Image service API endpoints ..."
openstack endpoint create --region RegionOne \
  image public http://${SET_IP}:9292

openstack endpoint create --region RegionOne \
  image internal http://${SET_IP}:9292

openstack endpoint create --region RegionOne \
  image admin http://${SET_IP}:9292


echo "Register quota limits (optional):"
# openstack --os-cloud devstack-system-admin registered limit create --service glance --default-limit 1000 --region RegionOne image_size_total
# openstack --os-cloud devstack-system-admin registered limit create --service glance --default-limit 1000 --region RegionOne image_stage_total
# openstack --os-cloud devstack-system-admin registered limit create --service glance --default-limit 100 --region RegionOne image_count_total
# openstack --os-cloud devstack-system-admin registered limit create --service glance --default-limit 100 --region RegionOne image_count_uploading


echo "Glance Install ..."
apt install -y glance
crudini --set /etc/glance/glance-api.conf database connection mysql+pymysql://glance:${STACK_PASSWD}@${SET_IP}/glance
crudini --set /etc/glance/glance-api.conf keystone_authtoken www_authenticate_uri http://${SET_IP}:5000
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_url http://${SET_IP}:5000
crudini --set /etc/glance/glance-api.conf keystone_authtoken memcached_servers ${SET_IP}:11211
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_type password
crudini --set /etc/glance/glance-api.conf keystone_authtoken project_domain_name Default
crudini --set /etc/glance/glance-api.conf keystone_authtoken user_domain_name Default
crudini --set /etc/glance/glance-api.conf keystone_authtoken project_name service
crudini --set /etc/glance/glance-api.conf keystone_authtoken username glance
crudini --set /etc/glance/glance-api.conf keystone_authtoken password ${STACK_PASSWD}
crudini --set /etc/glance/glance-api.conf paste_deploy flavor keystone
crudini --set /etc/glance/glance-api.conf glance_store stores file,http
crudini --set /etc/glance/glance-api.conf glance_store default_store file
crudini --set /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/

crudini --set /etc/glance/glance-api.conf oslo_limit auth_url http://${SET_IP}:5000
crudini --set /etc/glance/glance-api.conf oslo_limit auth_type password
crudini --set /etc/glance/glance-api.conf oslo_limit user_domain_id default
crudini --set /etc/glance/glance-api.conf oslo_limit username admin
crudini --set /etc/glance/glance-api.conf oslo_limit system_scope all
crudini --set /etc/glance/glance-api.conf oslo_limit password ${STACK_PASSWD}
ENDPOINT_ID="openstack endpoint list -c ID --interface admin -f value"
crudini --set /etc/glance/glance-api.conf oslo_limit endpoint_id ${ENDPOINT_ID}
crudini --set /etc/glance/glance-api.conf oslo_limit region_name RegionOne
openstack role add --user admin --user-domain Default --system all reader

echo "Glance Reg. DB ..."
su -s /bin/sh -c "glance-manage db_sync" glance

echo "[Finalize installation]"
service glance-api restart


echo "Glance Verify operation ..."
sync
. admin-openrc

echo "${CPU_ARCH}"
if [ "$CPU_ARCH" = "arm64" ]; then
  echo "arm64 cirros!!"
  wget http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-aarch64-disk.img
  glance image-create --name "cirros_arm64" --file cirros-0.4.0-aarch64-disk.img --disk-format qcow2 --container-format bare --visibility=public
else
  echo "amd64 cirros!!" 
  wget https://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img
  glance image-create --name "cirros_x86" --file cirros-0.4.0-x86_64-disk.img --disk-format qcow2 --container-format bare --visibility=public
fi

glance image-list
