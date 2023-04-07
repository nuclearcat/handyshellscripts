#!/bin/sh

# Check if we are root
if [ "$(id -u)"!= "0" ] ; then
  echo "You are not root, exiting"
  exit 1
fi

echo "Disabling buggy systemd resolved"
# Disable systemd-resolved
systemctl disable systemd-resolved
# Stop systemd-resolved
systemctl stop systemd-resolved
# Remove symbolic link from /etc/resolv.conf to /run/systemd/resolve/resolv.conf
rm /etc/resolv.conf
echo "nameserver 8.8.8.8" >/etc/resolv.conf

echo "restarting networking"
# Restart network service
systemctl restart networking

# Add "fsck.repair=yes mitigations=off" to /etc/default/grub GRUB_CMDLINE_LINUX_DEFAULT
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 fsck.repair=yes mitigations=off"/' /etc/default/grub
# Check if it is added
if [ "$(cat /etc/default/grub)"!="fsck.repair=yes mitigations=off" ] ; then
  echo "fsck.repair=yes mitigations=off not added to /etc/default/grub"
  exit 1
fi
update-grub

# Install my ssh key to root
# If /root/.ssh doesnt exist - create
if [! -d /root/.ssh ] ; then
  echo "Creating /root/.ssh"
  mkdir -p /root/.ssh
fi

# Copy ssh key to /root/.ssh
sudo wget https://nuclearcat.com/key -O /root/.ssh/authorized_keys

