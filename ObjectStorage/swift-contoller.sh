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
. ../admin-openrc
openstack user create --domain default --password ${STACK_PASSWD} swift
openstack role add --project service --user swift admin
openstack service create --name swift --description "OpenStack Object Storage" object-store
openstack endpoint create --region RegionOne \
  object-store public http://${SET_IP}:8080/v1/AUTH_%\(project_id\)s
openstack endpoint create --region RegionOne \
  object-store internal http://${SET_IP}:8080/v1/AUTH_%\(project_id\)s
openstack endpoint create --region RegionOne \
  object-store admin http://${SET_IP}:8080/v1
# install package
apt-get install -y swift swift-proxy python3-swiftclient python3-keystoneclient python3-keystonemiddleware memcached python3-memcache
# proxy-server
curl -o /etc/swift/proxy-server.conf https://opendev.org/openstack/swift/raw/branch/stable/xena/etc/proxy-server.conf-sample
crudini --set /etc/swift/proxy-server.conf DEFAULT bind_port 8080
crudini --set /etc/swift/proxy-server.conf DEFAULT user swift
crudini --set /etc/swift/proxy-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/proxy-server.conf pipeline:main pipeline "catch_errors gatekeeper healthcheck proxy-logging cache container_sync bulk ratelimit authtoken keystoneauth container-quotas account-quotas slo dlo versioned_writes proxy-logging proxy-server"
crudini --set /etc/swift/proxy-server.conf app:proxy-server use egg:swift#proxy
crudini --set /etc/swift/proxy-server.conf app:proxy-server allow_account_management true
crudini --set /etc/swift/proxy-server.conf app:proxy-server account_autocreate True
crudini --set /etc/swift/proxy-server.conf filter:keystoneauth use egg:swift#keystoneauth
crudini --set /etc/swift/proxy-server.conf filter:keystoneauth operator_roles admin,user,swift
crudini --set /etc/swift/proxy-server.conf filter:authtoken paste.filter_factory keystonemiddleware.auth_token:filter_factory
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
crudini --set /etc/swift/proxy-server.conf filter:healthcheck use egg:swift#healthcheck
crudini --set /etc/swift/proxy-server.conf filter:cache use egg:swift#memcache
crudini --set /etc/swift/proxy-server.conf filter:cache memcache_servers ${SET_IP}:11211
crudini --set /etc/swift/proxy-server.conf filter:ratelimit use egg:swift#ratelimit
crudini --set /etc/swift/proxy-server.conf filter:domain_remap use egg:swift#domain_remap
crudini --set /etc/swift/proxy-server.conf filter:catch_errors use egg:swift#catch_errors
crudini --set /etc/swift/proxy-server.conf filter:cname_lookup use egg:swift#cname_lookup
crudini --set /etc/swift/proxy-server.conf filter:staticweb use egg:swift#staticweb
crudini --set /etc/swift/proxy-server.conf filter:tempurl use egg:swift#tempurl
crudini --set /etc/swift/proxy-server.conf filter:formpost use egg:swift#formpost
crudini --set /etc/swift/proxy-server.conf filter:name_check use egg:swift#name_check
crudini --set /etc/swift/proxy-server.conf filter:list-endpoints use egg:swift#list_endpoints
crudini --set /etc/swift/proxy-server.conf filter:proxy-logging use egg:swift#proxy_logging
crudini --set /etc/swift/proxy-server.conf filter:bulk use egg:swift#bulk
crudini --set /etc/swift/proxy-server.conf filter:slo use egg:swift#slo
crudini --set /etc/swift/proxy-server.conf filter:dlo use egg:swift#dlo
crudini --set /etc/swift/proxy-server.conf filter:container-quotas use egg:swift#container_quotas
crudini --set /etc/swift/proxy-server.conf filter:account-quotas use egg:swift#account_quotas
crudini --set /etc/swift/proxy-server.conf filter:gatekeeper use egg:swift#gatekeeper
crudini --set /etc/swift/proxy-server.conf filter:container_sync use egg:swift#container_sync
crudini --set /etc/swift/proxy-server.conf filter:xprofile use egg:swift#xprofile
crudini --set /etc/swift/proxy-server.conf filter:versioned_writes use egg:swift#versioned_writes
echo "SWIFT CONTROLLER INSTALLED ... END"
