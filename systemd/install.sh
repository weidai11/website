#!/usr/bin/env bash

# This script installs bitvise-backup as a system service. The Systemd units (timer and service)
# are located in the Website GitHub. The backup script (bitvise-backup) is located in Root's
# home directory and not GitHub because passwords are hardcoded in the script.

if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

if [[ -z $(command -v systemctl 2>/dev/null) ]]; then
    echo "systemctl not found"
    exit 1
fi

if [[ ! -d /etc/systemd/system ]]; then
    echo "Systemd directory not found"
    exit 1
fi

########## Bitvise backup script ##########

# Clean previous installations, if present
systemctl disable bitvise-backup.service &>/dev/null
systemctl disable bitvise-backup.timer &>/dev/null
find /etc/systemd -name 'bitvise-backup.*' -exec rm -f {} \;

# Copy our Systemd units
cp bitvise-backup.service /etc/systemd/system
cp bitvise-backup.timer /etc/systemd/system

# Copy our backup script
cp "/root/backup-scripts/bitvise-backup" /usr/sbin/bitvise-backup
chown root:root /usr/sbin/bitvise-backup
chmod u=rwx,g=rx,o= /usr/sbin/bitvise-backup

# Enable bitvise-backup timer
if ! systemctl enable bitvise-backup.timer; then
    echo "Failed to enable bitvise-backup.timer"
    exit 1
fi

# Start bitvise-backup timer
if ! systemctl start bitvise-backup.timer; then
    echo "Failed to start bitvise-backup.timer"
    exit 1
fi

echo "Installed bitvise-backup service"

########## Gdrive backup script ##########

# Clean previous installations, if present
systemctl disable gdrive-backup.service &>/dev/null
systemctl disable gdrive-backup.timer &>/dev/null
find /etc/systemd -name 'gdrive-backup.*' -exec rm -f {} \;

# Copy our Systemd units
cp gdrive-backup.service /etc/systemd/system
cp gdrive-backup.timer /etc/systemd/system

# Copy our backup script
cp "/root/backup-scripts/gdrive-backup" /usr/sbin/gdrive-backup
chown root:root /usr/sbin/gdrive-backup
chmod u=rwx,g=rx,o= /usr/sbin/gdrive-backup

# Enable gdrive-backup timer
if ! systemctl enable gdrive-backup.timer; then
    echo "Failed to enable gdrive-backup.timer"
    exit 1
fi

# Start gdrive-backup timer
if ! systemctl start gdrive-backup.timer; then
    echo "Failed to start gdrive-backup.timer"
    exit 1
fi

echo "Installed gdrive-backup service"

########## Systemd services ##########

# Reload services
if ! systemctl daemon-reload 2>/dev/null; then
    echo "Failed to daemon-reload"
fi

if ! systemctl reset-failed; then
    echo "Failed to reset-failed"
fi

exit 0
