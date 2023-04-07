#!/bin/bash
# Check if we are root
if [ "$(id -u)" != "0" ] ; then
  echo "You are not root, exiting"
  exit 1
fi
# Check if we are /usr/local/bin/backup.sh
if [! $0 = /usr/local/bin/backup.sh ] ; then
  echo "You are not /usr/local/bin/backup.sh, but $0 exiting"
  exit 1
fi

# Check if backup.service exist in systemd
if [! -f /etc/systemd/system/backup.service ] ; then
  echo "Backup.service does not exist, creating"
  # Create backup.service
  echo "[Unit]\nDescription=Backup\n" > /etc/systemd/system/backup.service  
  echo "[Service]\nExecStart=/usr/local/bin/backup.sh\nType=oneshot\n" >> /etc/systemd/system/backup.service
  echo "[Install]\nWantedBy=multi-user.target" >> /etc/systemd/system/backup.service
  # Create backup.timer that runs each day at 3am
  echo "[Unit]\nDescription=Backup\n" > /etc/systemd/system/backup.timer
  echo "[Timer]\nOnCalendar=*-*-* 03:00:00" >> /etc/systemd/system/backup.service
  echo "[Install]\nWantedBy=multi-user.target" >> /etc/systemd/system/backup.timer
  # Reload
  systemctl daemon-reload
  # Enable timer
  systemctl enable backup.timer
fi