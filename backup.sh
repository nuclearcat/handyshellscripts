#!/bin/bash
# Check if we are root
if [ "$(id -u)" != "0" ] ; then
  echo "You are not root, exiting"
  exit 1
fi

# Is it ubuntu or debian? For now i didnt tested anywhere else
if [ "$(lsb_release -c)"!= "Ubuntu" || "$(lsb_release -c)"!= "Debian" ] ; then
  echo "This script is only for ubuntu/debian"
  exit 1
fi

# Lookup /proc/self/exe assign to variable proc_self_exe
proc_self_exe=$(readlink /proc/self/exe)

if [ "$proc_self_exe" != "/usr/local/bin/backup.sh" ] ; then
  echo "You are not /usr/local/bin/backup.sh, but $0"
  # Does /usr/local/bin/backup.sh exist? if not install from
  # https://raw.githubusercontent.com/nuclearcat/handyshellscripts/main/backup.sh
  if [ ! -f /usr/local/bin/backup.sh ] ; then
  echo "Installing backup.sh" 
  wget -O /usr/local/bin/backup.sh https://raw.githubusercontent.com/nuclearcat/handyshellscripts/main/backup.sh
  chmod +x /usr/local/bin/backup.sh
  fi
fi

# Check if backup.service exist in systemd
if [ ! -f /etc/systemd/system/backup.service ] ; then
  printf "Backup.service does not exist, creating"
  # Create backup.service
  printf "[Unit]\nDescription=Backup\n" > /etc/systemd/system/backup.service
  printf "[Service]\nExecStart=/usr/local/bin/backup.sh\nType=oneshot\n" >> /etc/systemd/system/backup.service
  printf "[Install]\nWantedBy=multi-user.target" >> /etc/systemd/system/backup.service
  # Create backup.timer that runs each day at 3am
  printf "[Unit]\nDescription=Backup\n" > /etc/systemd/system/backup.timer
  printf "[Timer]\nOnCalendar=*-*-* 03:00:00" >> /etc/systemd/system/backup.timer
  printf "[Install]\nWantedBy=multi-user.target" >> /etc/systemd/system/backup.timer
  # Reload
  systemctl daemon-reload
  # Enable timer
  systemctl enable backup.timer
fi
