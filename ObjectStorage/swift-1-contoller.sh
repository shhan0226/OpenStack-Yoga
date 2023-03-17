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
# Swift-Controller
##################################
echo "Swift Controller!!"
## Controller Node :
. ../admin-openrc
openstack user create --domain default --password ${STACK_PASSWD} swift
openstack role add --project service --user swift admin
openstack service create --name swift --description "OpenStack Object Storage" object-store
openstack endpoint create --region RegionOne object-store public http://${SET_IP}:8080/v1/AUTH_%\(project_id\)s
openstack endpoint create --region RegionOne object-store internal http://${SET_IP}:8080/v1/AUTH_%\(project_id\)s
openstack endpoint create --region RegionOne object-store admin http://${SET_IP}:8080/v1

##################################
# Swift-proxy Node
##################################
# install package
apt-get install -y swift swift-proxy python3-swiftclient python3-keystoneclient python3-keystonemiddleware memcached python3-memcache python3-webob

# proxy-server
#curl -o /etc/swift/proxy-server.conf https://opendev.org/openstack/swift/raw/branch/stable/xena/etc/proxy-server.conf-sample
curl -o /etc/swift/proxy-server.conf https://opendev.org/openstack/swift/raw/branch/master/etc/proxy-server.conf-sample

crudini --set /etc/swift/proxy-server.conf DEFAULT bind_port 8080
crudini --set /etc/swift/proxy-server.conf DEFAULT user swift
crudini --set /etc/swift/proxy-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/proxy-server.conf pipeline:main pipeline "catch_errors gatekeeper healthcheck proxy-logging cache container_sync bulk ratelimit authtoken keystoneauth container-quotas account-quotas slo dlo versioned_writes proxy-logging proxy-server"
crudini --set /etc/swift/proxy-server.conf app:proxy-server use egg:swift#proxy
crudini --set /etc/swift/proxy-server.conf app:proxy-server account_autocreate True
crudini --set /etc/swift/proxy-server.conf filter:keystoneauth use egg:swift#keystoneauth
crudini --set /etc/swift/proxy-server.conf filter:keystoneauth operator_roles admin,user,swift,member
crudini --set /etc/swift/proxy-server.conf filter:authtoken "paste.filter_factory" "keystonemiddleware.auth_token:filter_factory"
crudini --set /etc/swift/proxy-server.conf filter:authtoken www_authenticate_uri http://${SET_IP}:5000
crudini --set /etc/swift/proxy-server.conf filter:authtoken auth_url http://${SET_IP}:5000
crudini --set /etc/swift/proxy-server.conf filter:authtoken memcached_servers ${SET_IP}:11211
crudini --set /etc/swift/proxy-server.conf filter:authtoken auth_type password
crudini --set /etc/swift/proxy-server.conf filter:authtoken project_domain_id default
crudini --set /etc/swift/proxy-server.conf filter:authtoken user_domain_id default
crudini --set /etc/swift/proxy-server.conf filter:authtoken project_name service
crudini --set /etc/swift/proxy-server.conf filter:authtoken username swift
crudini --set /etc/swift/proxy-server.conf filter:authtoken password ${STACK_PASSWD}
crudini --set /etc/swift/proxy-server.conf filter:authtoken delay_auth_decision True
crudini --set /etc/swift/proxy-server.conf filter:cache use egg:swift#memcache
crudini --set /etc/swift/proxy-server.conf filter:cache memcache_servers ${SET_IP}:11211

##################################
# Rings
##################################
## Controller node:

# account
swift-ring-builder /etc/swift/account.builder create 10 3 1
#swift-ring-builder /etc/swift/account.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6202 --device sdb --weight 100 
#swift-ring-builder /etc/swift/account.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6202 --device sdc --weight 100
swift-ring-builder /etc/swift/account.builder add --region 1 --zone 1 --ip 192.168.2.53 --port 6202 --device sdb --weight 100 
swift-ring-builder /etc/swift/account.builder add --region 1 --zone 1 --ip 192.168.2.53 --port 6202 --device sdc --weight 100 
swift-ring-builder /etc/swift/account.builder add --region 1 --zone 2 --ip 192.168.2.54 --port 6202 --device sdb --weight 100 
swift-ring-builder /etc/swift/account.builder add --region 1 --zone 2 --ip 192.168.2.54 --port 6202 --device sdc --weight 100 
swift-ring-builder /etc/swift/account.builder
swift-ring-builder /etc/swift/account.builder rebalance

# container
swift-ring-builder /etc/swift/container.builder create 10 3 1
#swift-ring-builder /etc/swift/container.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6201 --device sdb --weight 100
#swift-ring-builder /etc/swift/container.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6201 --device sdc --weight 100
swift-ring-builder /etc/swift/container.builder add --region 1 --zone 1 --ip 192.168.2.53 --port 6201 --device sdb --weight 100
swift-ring-builder /etc/swift/container.builder add --region 1 --zone 1 --ip 192.168.2.53 --port 6201 --device sdc --weight 100
swift-ring-builder /etc/swift/container.builder add --region 1 --zone 2 --ip 192.168.2.54 --port 6201 --device sdb --weight 100
swift-ring-builder /etc/swift/container.builder add --region 1 --zone 2 --ip 192.168.2.54 --port 6201 --device sdc --weight 100
swift-ring-builder /etc/swift/container.builder
swift-ring-builder /etc/swift/container.builder rebalance

# object
swift-ring-builder /etc/swift/object.builder create 10 3 1
#swift-ring-builder /etc/swift/object.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6200 --device sdb --weight 100
#swift-ring-builder /etc/swift/object.builder add --region 1 --zone 1 --ip ${SET_IP} --port 6200 --device sdc --weight 100
swift-ring-builder /etc/swift/object.builder add --region 1 --zone 1 --ip 192.168.2.53 --port 6200 --device sdb --weight 100
swift-ring-builder /etc/swift/object.builder add --region 1 --zone 1 --ip 192.168.2.53 --port 6200 --device sdc --weight 100
swift-ring-builder /etc/swift/object.builder add --region 1 --zone 2 --ip 192.168.2.54 --port 6200 --device sdb --weight 100
swift-ring-builder /etc/swift/object.builder add --region 1 --zone 2 --ip 192.168.2.54 --port 6200 --device sdc --weight 100
swift-ring-builder /etc/swift/object.builder
swift-ring-builder /etc/swift/object.builder rebalance

##################################
# /etc/swift installation
##################################
chown swift. /etc/swift/*.gz

# /etc/swift/*.gz
ls /etc/swift
echo "scp account.ring.gz, container.ring.gz, object.ring.gz"
sudo apt-get install sshpass -y
sshpass -p "vraptor" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /etc/swift/*.gz vraptor@192.168.2.53:/home/vraptor
sshpass -p "vraptor" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /etc/swift/*.gz vraptor@192.168.2.54:/home/vraptor

# /etc/swift/swift.conf
curl -o /etc/swift/swift.conf https://opendev.org/openstack/swift/raw/branch/stable/${OPENSTACK_VER}/etc/swift.conf-sample
crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_suffix hash_swift_
crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_prefix hash_swift_
chown -R root:swift /etc/swift
sshpass -p "vraptor" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /etc/swift/swift.conf vraptor@192.168.2.53:/home/vraptor
sshpass -p "vraptor" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /etc/swift/swift.conf vraptor@192.168.2.54:/home/vraptor

# fin.
service memcached restart
service swift-proxy restart
. ../admin-openrc
openstack user list
openstack service list
openstack endpoint list | grep swift
openstack volume service list

echo "ADD /etc/hosts"
echo "192.168.2.52 x86cinder"
echo "192.168.2.53 x86sw1"
echo "192.168.2.54 x86sw2"
echo "SWIFT INSTALLED ... END"
