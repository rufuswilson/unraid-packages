ZerotierOne allows systems to join and participate in ZeroTier
virtual networks.

ZerotierOne is a client application that enables devices to join
ZeroTier virtual networks (typically configured and managed by a
network controller). It provides an encrypted and secure network
connectivity solution that can be used for a variety of purposes,
including VPN alternatives, remote access, distributed
applications, and more.

Since ZerotierOne needs the tun module to be loaded in order to
work, that is done in the start function of rc.zerotier-one.
If you wish you can make the module load from rc.modules.local.

The following can be used to start/stop ZerotierOne automatically:
/etc/rc.d/rc.local

  if [ -x /etc/rc.d/rc.zerotier-one ]; then
    /etc/rc.d/rc.zerotier-one start
  fi

/etc/rc.d/rc.local_shutdown
  if [ -x /etc/rc.d/rc.zerotier-one ]; then
    /etc/rc.d/rc.zerotier-one stop
  fi