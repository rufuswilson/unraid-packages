#!/bin/bash

chown -R root:root /usr/sbin/zerotier*
chmod -R 755 /usr/sbin/zerotier*


confld="/boot/config/plugins/zerotier"
varfld="/var/lib/zerotier-one"

# kill all processes listening to 9993
lsof -ti TCP:9993 | xargs -r kill -9
sleep 3s
if [[ -d "${varfld}" ]]; then
   rm -rf "${varfld}"
fi

# create directories
if [[ ! -d "${confld}" ]]; then
   mkdir "${confld}"
fi

# generate private key
if [[ ! -f "${confld}/identity.secret" ]]; then
    zerotier-one -i generate "${confld}/identity.secret" "${confld}/identity.public"
fi

# generate public key
if [[ ! -f "${confld}/identity.public" ]]; then
    zerotier-one -i getpublic "${confld}/identity.secret" > "${confld}/identity.public"
    echo "${confld}/identity.public written"
fi

# starting zerotier-one to populate var folder
timeout -k 3s 3s zerotier-one
sleep 5s
lsof -ti TCP:9993 | xargs -r kill -9
sleep 5s

# populate the zerotier-one var folder
cat "${confld}/identity.secret" > "${varfld}/identity.secret"
cat "${confld}/identity.public" > "${varfld}/identity.public"

if [[ -d "${confld}/networks.d" ]]; then
    if [[ ! -d "${varfld}/networks.d" ]]; then
        mkdir -p "${varfld}/networks.d"
    fi
    cp "${confld}/networks.d/"*.* "${varfld}/networks.d"
fi

# start daemon
zerotier-one -d

# timeout to wait for the daemon to have started
sleep 5s

zerotier-cli info
zerotier-cli listnetworks

# timeout to wait for the system to stabilize
sleep 5s

# add new interfaces to list of interfaces to listen to
cfgFile=/boot/config/network-extra.cfg
interfaces=$(zerotier-cli -j listnetworks | grep portDeviceName | sed -e 's/^.*"\([a-zA-Z0-9]*\)",.*$/\1/g')
for interface in ${interfaces}; do
    includes=$(cat "${cfgFile}" | grep include_ | sed -e 's/^.*="\([a-zA-Z0-9 ]*\)".*$/\1/g')
    if [[ ${includes} != *"${interface}"* ]]; then
        sed -i "s/^\(include_interfaces.*\)\"$/\1 ${interface}\"/g" "${cfgFile}"
    fi
done
cat "${cfgFile}"
