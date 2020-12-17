#!/usr/bin/env bash

# This script updates the artifacts in the website/systemd directory.

if ! wget -O bitvise-backup.service https://raw.githubusercontent.com/weidai11/website/master/systemd/bitvise-backup.service;
then
	echo "Failed to download bitvise-backup.service"
	exit 1
fi

if ! wget -O bitvise-backup.timer https://raw.githubusercontent.com/weidai11/website/master/systemd/bitvise-backup.timer;
then
	echo "Failed to download bitvise-backup.timer"
	exit 1
fi

if ! wget -O gdrive-backup.service https://raw.githubusercontent.com/weidai11/website/master/systemd/gdrive-backup.service;
then
	echo "Failed to download gdrive-backup.service"
	exit 1
fi

if ! wget -O gdrive-backup.timer https://raw.githubusercontent.com/weidai11/website/master/systemd/gdrive-backup.timer;
then
	echo "Failed to download gdrive-backup.timer"
	exit 1
fi

if ! wget -O system-update.service https://raw.githubusercontent.com/weidai11/website/master/systemd/system-update.service;
then
	echo "Failed to download system-update.service"
	exit 1
fi

if ! wget -O system-update.timer https://raw.githubusercontent.com/weidai11/website/master/systemd/system-update.timer;
then
	echo "Failed to download system-update.timer"
	exit 1
fi

if ! wget -O install.sh https://raw.githubusercontent.com/weidai11/website/master/systemd/install.sh;
then
	echo "Failed to download install.sh"
	exit 1
fi

if ! wget -O update.sh https://raw.githubusercontent.com/weidai11/website/master/systemd/update.sh;
then
	echo "Failed to download update.sh"
	exit 1
fi

if ! wget -O system-update.sh https://raw.githubusercontent.com/weidai11/website/master/systemd/system-update.sh;
then
	echo "Failed to download system-update.sh"
	exit 1
fi

chmod ug=rwx,o= install.sh update.sh system-update.sh

exit 0
