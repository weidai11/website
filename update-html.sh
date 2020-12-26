#!/usr/bin/env bash

# Use this script to move website artifacts, like *.html
# and *.css files, to the web server directory. The
# script sets ownership and permissions as required.

www_directory=/var/www/html

if [[ ($(id -u) != "0") ]]; then
    echo "You must be root to update the html"
    exit 1
fi

if [ ! -d "${www_directory}" ]; then
    echo "Unable to locate website directory"
    exit 1
fi

count=$(ls -1 *.html 2>/dev/null | wc -l)
if [ "${count}" -ne 0 ]; then
    mv *.html "${www_directory}"
fi

count=$(ls -1 *.svg 2>/dev/null | wc -l)
if [ "${count}" -ne 0 ]; then
    mv *.svg "${www_directory}"
fi

count=$(ls -1 *.css 2>/dev/null | wc -l)
if [ "${count}" -ne 0 ]; then
    mv *.css "${www_directory}"
fi

count=$(ls -1 *.png 2>/dev/null | wc -l)
if [ "${count}" -ne 0 ]; then
    mv *.png "${www_directory}"
fi

count=$(ls -1 *.ico 2>/dev/null | wc -l)
if [ "${count}" -ne 0 ]; then
    mv *.ico "${www_directory}"
fi

# Early Crypto++ filenames were crypto23.zip, etc.
count=$(ls -1 crypto*.zip 2>/dev/null | wc -l)
if [ "${count}" -ne 0 ]; then
    mv crypto*.zip "${www_directory}"
fi

count=$(ls -1 crypto*.sig 2>/dev/null | wc -l)
if [ "${count}" -ne 0 ]; then
    mv crypto*.sig "${www_directory}"
fi

# Ownership
chown root:apache "${www_directory}"
chown root:apache "${www_directory}"/*

# And permissions
IFS= find "${www_directory}" -maxdepth 1 -type d -print | while read -r dir
do
    chmod u=rwx,g=rx,o= "${dir}"
done

# And more permissions
IFS= find "${www_directory}" -maxdepth 1 -type f -print | while read -r file
do
    if file -b "${file}" | grep -q -E 'executable|script';
    then
        chmod u=rwx,g=rx,o= "${file}"
    else
        chmod u=rw,g=r,o= "${file}"
    fi
done

# Finally, set the date/time on the ZIP files
# This piece is the update-zip.sh script
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
