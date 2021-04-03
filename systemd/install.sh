#!/usr/bin/env bash

# This script installs bitvise-backup and gdrive-backup as system services.
# The Systemd units (timer and service) are located in the Website GitHub.
# The backup scripts depend upon /etc/cryptopp.conf for passwords and shared
# secrets.
#
# GDrive Backup is disabled at the moment. The GDrive backup requires a token
# that changes every 30 days. It is too much work to stay on top of.
#
# System Update is disabled at the moment. The VM has an Apt update unit that
# is preinstalled. We don't want to conflict with it.
#
# cryptopp.conf is not available in this GitHub because it holds passwords
# and shared secrets. You have to have a copy of it somewhere. It is one of
# those files that you should have an encrypted local copy somewhere, like
# on a local machine or in email.
#
# Also see https://github.com/weidai11/website/tree/master/systemd

#################### Administrivia ####################

if [[ $(id -u) != "0" ]]; then
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

#################### Bitvise backup script ####################

# Clean previous installations, if present
systemctl stop bitvise-backup.service &>/dev/null
systemctl stop bitvise-backup.timer &>/dev/null
systemctl disable bitvise-backup.service &>/dev/null
systemctl disable bitvise-backup.timer &>/dev/null
systemctl revert bitvise-backup.service &>/dev/null
find /etc/systemd -name 'bitvise-backup.*' -exec rm -f {} \;

# Copy our Systemd units
cp -p bitvise-backup.service /etc/systemd/system
cp -p bitvise-backup.timer /etc/systemd/system

# Copy our backup script
cp -p bitvise-backup /usr/sbin/bitvise-backup
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

#################### Gdrive backup script ####################

# Clean previous installations, if present
systemctl stop gdrive-backup.service &>/dev/null
systemctl stop gdrive-backup.timer &>/dev/null
systemctl disable gdrive-backup.service &>/dev/null
systemctl disable gdrive-backup.timer &>/dev/null
systemctl revert gdrive-backup.service &>/dev/null
find /etc/systemd -name 'gdrive-backup.*' -exec rm -f {} \;

########## BEGIN DISABLED ##########
if false; then

# Copy our Systemd units
cp -p gdrive-backup.service /etc/systemd/system
cp -p gdrive-backup.timer /etc/systemd/system

# Copy our backup script
cp -p gdrive-backup /usr/sbin/gdrive-backup
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

fi
########## END DISABLED ##########

#################### System update script ####################

# Clean previous installations, if present
systemctl stop system-update.service &>/dev/null
systemctl stop system-update.timer &>/dev/null
systemctl disable system-update.service &>/dev/null
systemctl disable system-update.timer &>/dev/null
systemctl revert system-update.timer &>/dev/null
find /etc/systemd -name 'system-update.*' -exec rm -f {} \;

########## BEGIN DISABLED ##########
if false; then

# Copy our Systemd units
cp -p system-update.service /etc/systemd/system
cp -p system-update.timer /etc/systemd/system

# Copy our update script
cp -p system-update.sh /usr/sbin/system-update.sh
chown root:root /usr/sbin/system-update.sh
chmod u=rwx,g=rx,o= /usr/sbin/system-update.sh

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

fi
########## END DISABLED ##########

#################### Systemd services ####################

# Reload services
if ! systemctl daemon-reload 2>/dev/null; then
    echo "Failed to daemon-reload"
fi

if ! systemctl reset-failed; then
    echo "Failed to reset-failed"
fi

exit 0
