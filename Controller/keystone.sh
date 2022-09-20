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

echo "$CONTROLLER_HOST"
echo "$COMPUTE_HOST"
echo "$SET_IP"
echo "$SET_IP2"
echo "$SET_IP_ALLOW"
echo "$INTERFACE_NAME_"
echo "$STACK_PASSWD"
echo "$CPU_ARCH"
echo "... set!!"


##################################
# Keystone
##################################
echo "Keystone !!"

echo "[Prerequisites]" 

echo "Keystone CREATE DB ..."
mysql -e "CREATE DATABASE keystone;"
mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '${STACK_PASSWD}';"
mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${STACK_PASSWD}';"
mysql -e "FLUSH PRIVILEGES;"

echo "[Install and configure components]"

echo "Keystone Install ..."
apt install -y keystone
crudini --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:${STACK_PASSWD}@${SET_IP}/keystone
crudini --set /etc/keystone/keystone.conf token provider fernet
echo "Keystone Reg DB ..."
su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
keystone-manage bootstrap --bootstrap-password ${STACK_PASSWD} \
  --bootstrap-admin-url http://${SET_IP}:5000/v3/ \
  --bootstrap-internal-url http://${SET_IP}:5000/v3/ \
  --bootstrap-public-url http://${SET_IP}:5000/v3/ \
  --bootstrap-region-id RegionOne

echo "[Configure the Apache HTTP server]"

echo "Keystone - Apache HTTP server ..."
echo "ServerName ${SET_IP}" >> /etc/apache2/apache2.conf

echo "[Finalize the installation]"

echo "Restart the Apache service:"
service apache2 restart
export OS_USERNAME=admin
export OS_PASSWORD=${STACK_PASSWD}
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://${SET_IP}:5000/v3
export OS_IDENTITY_API_VERSION=3


##################################
# admin-openrc
##################################
cat > admin-openrc << EOF
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=stack
export OS_AUTH_URL=http://${SET_IP}:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
cat > demo-openrc << EOF
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=myproject
export OS_USERNAME=myuser
export OS_PASSWORD=stack
export OS_AUTH_URL=http://${SET_IP}:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
. admin-openrc


##################################
# Create a domain, projects, users, and roles
##################################
echo "Keystone - domain, projects, users, and roles ..."
openstack domain create --description "An Example Domain" example

openstack project create --domain default \
  --description "Service Project" service

openstack project create --domain default \
  --description "Demo Project" myproject

openstack user create --domain default \
  --password ${STACK_PASSWD} myuser

openstack role create myrole

openstack role add --project myproject --user myuser myrole


echo "Keystone Verify operation ..."
#unset OS_AUTH_URL OS_PASSWORD

#. admin-openrc
#openstack --os-auth-url http://controller:5000/v3 \
#--os-project-domain-name Default --os-user-domain-name Default \
#--os-project-name admin --os-username admin token issue


##################################
# Create OpenStack client environment scripts
##################################
#. admin-openrc
#openstack token issue
