#!/usr/bin/env bash

# This script updates the artifacts in the website/systemd directory.

echo "Downloading bitvise-backup.service..."
if ! wget -q -O bitvise-backup.service https://raw.githubusercontent.com/weidai11/website/master/systemd/bitvise-backup.service;
then
    echo "Failed to download bitvise-backup.service"
    exit 1
fi

echo "Downloading bitvise-backup.timer..."
if ! wget -q -O bitvise-backup.timer https://raw.githubusercontent.com/weidai11/website/master/systemd/bitvise-backup.timer;
then
    echo "Failed to download bitvise-backup.timer"
    exit 1
fi

echo "Downloading bitvise-backup script..."
if ! wget -q -O bitvise-backup https://raw.githubusercontent.com/weidai11/website/master/systemd/bitvise-backup;
then
    echo "Failed to download bitvise-backup script"
    exit 1
fi

echo "Downloading gdrive-backup.service..."
if ! wget -q -O gdrive-backup.service https://raw.githubusercontent.com/weidai11/website/master/systemd/gdrive-backup.service;
then
    echo "Failed to download gdrive-backup.service"
    exit 1
fi

echo "Downloading gdrive-backup.timer..."
if ! wget -q -O gdrive-backup.timer https://raw.githubusercontent.com/weidai11/website/master/systemd/gdrive-backup.timer;
then
    echo "Failed to download gdrive-backup.timer"
    exit 1
fi

echo "Downloading gdrive-backup script..."
if ! wget -q -O gdrive-backup https://raw.githubusercontent.com/weidai11/website/master/systemd/gdrive-backup;
then
    echo "Failed to download gdrive-backup script"
    exit 1
fi

echo "Downloading system-update.service..."
if ! wget -q -O system-update.service https://raw.githubusercontent.com/weidai11/website/master/systemd/system-update.service;
then
    echo "Failed to download system-update.service"
    exit 1
fi

echo "Downloading system-update.timer..."
if ! wget -q -O system-update.timer https://raw.githubusercontent.com/weidai11/website/master/systemd/system-update.timer;
then
    echo "Failed to download system-update.timer"
    exit 1
fi

echo "Downloading system-update.sh..."
if ! wget -q -O system-update.sh https://raw.githubusercontent.com/weidai11/website/master/systemd/system-update.sh;
then
    echo "Failed to download system-update.sh"
    exit 1
fi

echo "Downloading install.sh..."
if ! wget -q -O install.sh https://raw.githubusercontent.com/weidai11/website/master/systemd/install.sh;
then
    echo "Failed to download install.sh"
    exit 1
fi

echo "Downloading update.sh..."
if ! wget -q -O update.sh https://raw.githubusercontent.com/weidai11/website/master/systemd/update.sh;
then
    echo "Failed to download update.sh"
    exit 1
fi

echo "Finished downloading warez."

chmod ug=rwx,o= install.sh update.sh bitvise-backup gdrive-backup system-update.sh

exit 0
