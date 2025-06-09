#!/bin/bash


# mount share
#sudo mount -t 9p -o trans=virtio,version=9p2000.L,posixacl,cache=loose slackpkgs slackpkgs
sudo mount -t 9p -o trans=virtio slackpkgs slackpkgs


# download slackpkg
wget https://www.slackpkg.org/stable/slackpkg-15.0.10-noarch-1.txz -O slackpkg.txz
# install slackpkg
sudo installpkg slackpkg.txz

# download slackpkg+
wget https://github.com/alienbob/slackpkgplus/releases/download/1.8.2/slackpkg+-1.8.2-noarch-1alien.txz -O slackpkg+.txz
# install slackpkg+
sudo installpkg slackpkg+.txz

# activate extra repos 
sed -i -e 's#/multilib/15.0/#/multilib/current/#g' /etc/slackpkg/slackpkgplus.conf
sed -i -e 's#/sbrepos/15.0/#/sbrepos/current/#g' /etc/slackpkg/slackpkgplus.conf
sed -i -e 's#/restricted_sbrepos/15.0/#/restricted_sbrepos/current/#g' /etc/slackpkg/slackpkgplus.conf
sed -i -E "s/^#(MIRRORPLUS\['(multilib|alienbob|restricted)'\]=https)/\1/g" /etc/slackpkg/slackpkgplus.conf
sed -i -E "s/^(REPOPLUS=\() .*$/\1 slackpkgplus restricted alienbob multilib )/g" /etc/slackpkg/slackpkgplus.conf

# update slackpkg repositories
sudo slackpkg update
# upgrade all packages
sudo slackpkg upgrade-all

# install dependencies
sudo slackpkg install make gcc gcc-g++ 


# install qemu-guest-agent
sudo slackpkg install qemu-guest-agent
echo """
if [ -x /etc/rc.d/rc.qemu-ga ]; then
  echo "Starting QEMU Guest Agent:    /etc/rc.d/rc.qemu-ga start"
  /etc/rc.d/rc.qemu-ga start
fi""" | sudo tee -a /etc/rc.d/rc.local
echo """
if [ -x /etc/rc.d/rc.qemu-ga ]; then
  echo "Stopping QEMU Guest Agent:    /etc/rc.d/rc.qemu-ga stop"
  /etc/rc.d/rc.qemu-ga stop
fi""" | sudo tee -a /etc/rc.d/rc.local_shutdown
sudo chmown root:root /etc/rc.d/rc.qemu-ga
sudo chmod 755 /etc/rc.d/rc.qemu-ga
sudo /etc/rc.d/rc.qemu-ga start


# install docker
sudo slackpkg install docker runc containerd docker-compose
echo """
if [ -x /etc/rc.d/rc.docker ]; then
    echo \"Starting docker:    /etc/rc.d/rc.docker start\"
    /etc/rc.d/rc.docker start
fi""" | sudo tee -a /etc/rc.d/rc.local
echo """
if [ -x /etc/rc.d/rc.docker ]; then
    echo \"Stopping docker:    /etc/rc.d/rc.docker stop\"
    /etc/rc.d/rc.docker stop
fi""" | sudo tee -a /etc/rc.d/rc.local_shutdown
sudo chmown root:root /etc/rc.d/rc.docker
sudo chmod 755 /etc/rc.d/rc.docker
sudo ln /run/docker/containerd /usr/bin/containerd
sudo /etc/rc.d/rc.docker start
sudo groupadd -r -g 281 docker
sudo usermod -a -G docker ${USER}


# download sbopkg
wget https://github.com/sbopkg/sbopkg/releases/download/0.38.3/sbopkg-0.38.3-noarch-1_wsr.tgz -O sbopkg.tgz
# install sbopkg
sudo installpkg sbopkg.tgz

# update local mirror
sudo sbopkg -r

# update sbopkg
sudo sbopkg -u



# What to do it newer kernel
sudo slackpkg download kernel-generic kernel-headers
sudo installpkg /var/cache/packages/./slackware64/a/kernel-generic-6.12.32-x86_64-1.txz
sudo installpkg /var/cache/packages/./slackware64/a/kernel-headers-6.12.32-x86-1.txz
cd /boot/
sudo mkinitrd -c -k 6.12.32 -m ext4
sudo cp /boot/initrd.gz /boot/efi/EFI/Slackware/initrd-6.12.32.gz
sudo cp /boot/vmlinuz-6.12.32 /boot/efi/EFI/Slackware/vmlinuz-6.12.32
# manually edit /boot/efi/EFI/Slackware/elilo.conf
#   change the default to the new kernel label
#            default=6.12.32
#   add new image 
#            image=vmlinuz-6.12.32
#                label=6.12.32
#                initrd=initrd-6.12.32.gz
#                read-only
#                append="root=/dev/sda3 vga=normal ro"
