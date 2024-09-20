#!/bin/bash
set -eux

ip1=$1
fqdn=$(hostname --fqdn)

# configure apt for non-interactive mode.
export DEBIAN_FRONTEND=noninteractive

# make sure the local apt cache is up to date.
while true; do
    apt-get update && break || sleep 5
done

# configure the network for NATting.
ifdown vmbr0
cat >/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet manual

auto vmbr0
iface vmbr0 inet static
    address $ip1
    netmask 255.255.255.0
    bridge_ports eth1
    bridge_stp off
    bridge_fd 0
    # enable IP forwarding. needed to NAT and DNAT.
    post-up   echo 1 >/proc/sys/net/ipv4/ip_forward
    # NAT through eth0.
    post-up   iptables -t nat -A POSTROUTING -s '$ip1/24' ! -d '$ip1/24' -o eth0 -j MASQUERADE
    post-down iptables -t nat -D POSTROUTING -s '$ip1/24' ! -d '$ip1/24' -o eth0 -j MASQUERADE

auto eth2
iface eth2 inet manual

auto eth3
iface eth3 inet manual

EOF
sed -i -E "s,^[^ ]+( .*pve.*)\$,$ip1\1," /etc/hosts
sed 's,\\,\\\\,g' >/etc/issue <<'EOF'

     _ __  _ __ _____  ___ __ ___   _____  __ __   _____
    | '_ \| '__/ _ \ \/ / '_ ` _ \ / _ \ \/ / \ \ / / _ \
    | |_) | | | (_) >  <| | | | | | (_) >  <   \ V /  __/
    | .__/|_|  \___/_/\_\_| |_| |_|\___/_/\_\   \_/ \___|
    | |
    |_|

EOF
cat >>/etc/issue <<EOF
    https://$ip1:8006/
EOF
ifup vmbr0
ifup eth1

# disable the "You do not have a valid subscription for this server. Please visit www.proxmox.com to get a list of available options."
# message that appears each time you logon the web-ui.
# NB this file is restored when you (re)install the pve-manager package.
echo 'Proxmox.Utils.checked_command = function(o) { o(); };' >>/usr/share/pve-manager/js/pvemanagerlib.js

# configure the shell.
cat >/etc/profile.d/login.sh <<'EOF'
[[ "$-" != *i* ]] && return
export EDITOR=nano
export PAGER=less
alias l='ls -lF --color'
alias ll='l -a'
alias h='history 25'
alias j='jobs -l'
EOF

cat >/etc/inputrc <<'EOF'
set input-meta on
set output-meta on
set show-all-if-ambiguous on
set completion-ignore-case on
"\e[A": history-search-backward
"\e[B": history-search-forward
"\eOD": backward-word
"\eOC": forward-word
EOF

# configure the motd.
# NB this was generated at http://patorjk.com/software/taag/#p=display&f=Big&t=proxmox%20ve.
#    it could also be generated with figlet.org.
cat >/etc/motd <<'EOF'

     _ __  _ __ _____  ___ __ ___   _____  __ __   _____
    | '_ \| '__/ _ \ \/ / '_ ` _ \ / _ \ \/ / \ \ / / _ \
    | |_) | | | (_) >  <| | | | | | (_) >  <   \ V /  __/
    | .__/|_|  \___/_/\_\_| |_| |_|\___/_/\_\   \_/ \___|
    | |
    |_|

EOF

## install ifupdown2 (necesario para recargar a configuración da rede 
## desde a GUI sen reinicar a VM)
apt-get install -y ifupdown2
#apply initial network changes
if [ -e /etc/network/interfaces.new ]; then
  mv /etc/network/interfaces.new /etc/network/interfaces
fi
ifreload -c


#enable KVM nested virtualization
if [ -d /sys/module/kvm_intel2 ]; then
  echo "options kvm-intel nested=Y" > /etc/modprobe.d/kvm-intel.conf
  modprobe -r kvm_intel
  modprobe kvm_intel
elif [ -d /sys/module/kvm_amd ]; then
  echo "options kvm-amd nested=1" > /etc/modprobe.d/kvm-amd.conf
  modprobe -r kvm_amd
  modprobe kvm_amd
else
  printf 'KVM kernel module (Intel/AMD) not configured\n' >&2
  echo "KVM kernel module (Intel/AMD) not configured" > /vagrant/kvm-warning.txt 2>&1
fi
