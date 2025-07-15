How to get it to work

Please add repo to sources.list as explained in parent README.md

Update your sources
 >>> un-get update

Install the package
 >>> un-get install zerotier-one


The package configuration should be stored in:
    /boot/config/plugins/zerotier

It will be automatically copied to the var configuration folder once the package is installed (at every boot as well):
    /var/lib/zerotier-one

The identity files (secret and public) will be generated if not available already.

For the list of networks, one can create a file <NETWORK ID>.conf in the networks.d folder. Zerotier will connect to this network on the next boot.

If the user prefers to use the cli interface to join networks, they should make a copy of the network conf files into the package configuration folder so that zerotier will connect to those networks on the next reboot.

If the user wants be able to connect immediately to the new networks, they should add the interfaces created for each new network (zt\*) to the "Include listening interfaces" under "Settings/NetworkSettings/interface extra". The interface names can be obtained with the following command.
 >>> zerotier-cli listnetworks


*** How to uninstall

Stop the daemon
 >>> killall zerotier-one

Make sure daemon is stopped
 >>> lsof -ti TCP:9993 | xargs -r kill -9

Uninstall package
 >>> un-get remove zerotier-one

Cleanup configuration
 >>> rm -rf /var/lib/zerotier-one


killall zerotier-one
lsof -ti TCP:9993 | xargs -r kill -9
rm -rf /var/lib/zerotier-one
un-get remove zerotier-one


un-get update zerotier-one
un-get install zerotier-one
