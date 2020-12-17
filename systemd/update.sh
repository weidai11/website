#!/usr/bin/env bash

# This script updates the other artifacts in the Stsyemd directory.

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

chmod ug=rwx,o= install.sh update.sh

exit 0
