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

The identity files (secret and public) will be generated if not available already. For the list of networks, one can create a file <NETWORK ID>.conf in the networks.d folder. If the user prefers to use the cli interface to join networks, they should make a copy of the network conf files into the package configuration folder.
