#!/bin/bash

chown -R root:root /usr/sbin/zerotier*
chmod -R 755 /usr/sbin/zerotier*


confld="/boot/config/plugins/zerotier"
varfld="/var/lib/zerotier-one"

# kill all processes listening to 9993
lsof -ti TCP:9993 | xargs kill -9
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
lsof -ti TCP:9993 | xargs kill -9

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
