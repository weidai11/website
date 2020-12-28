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
    # This fetches the newest timestamp from the ZIP file.
    # It is in format '01-17-1998 20:19' or '1998-17-01 20:19'
    ft=$(unzip -l "${file}" 2>&1 | head -n -2 | tail -n +4 | cut -b 12-27 | sort -r | uniq | head -n 1)

    # Fix date/time string. It is either '01-17-1998 20:19' (CentOS) or
    # '1998-17-01 20:19' (Ubuntu). I guess unzip changed its output format.
    # Check length of the first field. 2 digits is month, 4 digits is year.
    # We check for 3 instead of 2 because Posix cut adds a newline.
    len=$(echo -n ${ft} | cut -f 1 -d '-' | wc -c)
    if [[ ${len} -eq 3 ]];
    then
        # Fix date. '01-17-1998 20:19' -> '1998-01-17 20:19'.
        month=$(echo -n ${ft} | cut -b 1-2)
        day=$(echo -n ${ft} | cut -b 4-5)
        year=$(echo -n ${ft} | cut -b 7-10)
        seconds=$(echo -n ${ft} | cut -b 12-)
        ft="${year}-${month}-${day} ${seconds}"
    fi

    # echo "Setting ${file} to ${ft}"
    touch -d "${ft}" "${file}"

    # Set date/time on sig file.
    if [ -f "${file}.sig" ];
    then
        touch -d "${ft}" "${file}.sig"
    fi
done

exit 0
