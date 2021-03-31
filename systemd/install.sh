#!/usr/bin/env bash

# This script installs bitvise-backup as a system service. The Systemd units (timer and service)
# are located in the Website GitHub. The backup script (bitvise-backup) is located in Root's
# home directory and not GitHub because passwords are hardcoded in the script.

if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

if [[ ! $(command -v systemctl 2>/dev/null) ]]; then
    echo "systemctl not found"
    exit 1
fi

if [[ ! -d /etc/systemd/system ]]; then
    echo "Systemd directory not found"
    exit 1
fi

if [[ ! -f bitvise-backup.timer || ! -f bitvise-backup.service ]]; then
    echo "bitvise-backup not found"
    echo "Try running update.sh to fetch the Systemd units"
    exit 1
fi

if [[ ! -f gdrive-backup.timer || ! -f gdrive-backup.service ]]; then
    echo "gdrive-backup not found"
    echo "Try running update.sh to fetch the Systemd units"
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
if [[ -f "/root/backup-scripts/gdrive-backup" ]]; then
    cp "/root/backup-scripts/bitvise-backup" /usr/sbin/bitvise-backup
    chown root:root /usr/sbin/bitvise-backup
    chmod u=rwx,g=rx,o= /usr/sbin/bitvise-backup
else
    "WARNING: /root/backup-scripts/gdrive-backup does not exist"
fi

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
if [[ -f "/root/backup-scripts/gdrive-backup" ]]; then
    cp "/root/backup-scripts/gdrive-backup" /usr/sbin/gdrive-backup
    chown root:root /usr/sbin/gdrive-backup
    chmod u=rwx,g=rx,o= /usr/sbin/gdrive-backup
else
    "WARNING: /root/backup-scripts/gdrive-backup does not exist"
fi

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

########## System update script ##########

# Begin DISABLE for the moment
if false; then

# Clean previous installations, if present
systemctl disable system-update.service &>/dev/null
systemctl disable system-update.timer &>/dev/null
find /etc/systemd -name 'system-update.*' -exec rm -f {} \;

# Copy our Systemd units
cp system-update.service /etc/systemd/system
cp system-update.timer /etc/systemd/system

# Copy our backup script
if [[ -f "/root/backup-scripts/system-update.sh" ]]; then
    cp "/root/backup-scripts/system-update.sh" /usr/sbin/system-update.sh
    chown root:root /usr/sbin/system-update.sh
    chmod u=rwx,g=rx,o= /usr/sbin/system-update.sh
else
    "WARNING: /root/backup-scripts/system-update.sh does not exist"
fi

# Enable system-update timer
if ! systemctl enable system-update.timer; then
    echo "Failed to enable system-update.timer"
    exit 1
fi

# Start system-update timer
if ! systemctl start system-update.timer; then
    echo "Failed to start system-update.timer"
    exit 1
fi

echo "Installed system-update service"

# End DISABLE for the moment
fi

########## Systemd services ##########

# Reload services
if ! systemctl daemon-reload 2>/dev/null; then
    echo "Failed to daemon-reload"
fi

if ! systemctl reset-failed; then
    echo "Failed to reset-failed"
fi

exit 0
