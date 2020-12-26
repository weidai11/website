#!/usr/bin/env bash

# This script restores ZIP filetimes after other scripts run,
# like scripts to change permissions on $www_directory.

www_directory=/var/www/html

if [[ ($(id -u) != "0") ]]; then
    echo "You must be root to update the html"
    exit 1
fi

if [ ! -d "${www_directory}" ]; then
    echo "Unable to locate website directory"
    exit 1
fi

IFS= find "${www_directory}" -maxdepth 1 -type f -name '*.zip' -print | while read -r file
do
    # This fetches the newest timestamp from the ZIP file. It is in format '01-17-1998 20:19'
    original=$(unzip -l "${file}" 2>&1 | head -n -2 | tail -n +4 | cut -b 12-27 | sort -r | uniq | head -n 1)
    # '01-17-1998 20:19' -> '1998-01-17 20:19'
    original=$(echo ${original} | sed 's/\([^-]*-[^-]*\)-\(....\)/\2-\1/')
    # echo "Setting ${file} to ${original}"
    touch -d "${original}" "${file}"
done

exit 0
