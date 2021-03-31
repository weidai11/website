#!/usr/bin/env bash

# Use this script to move website artifacts, like *.html
# and *.css files, to the web server directory. The
# script sets ownership and permissions as required.

# Location of the website
www_directory=/var/www/html

# Red Hat uses root:apache, Debian uses root:www-data
if grep -q www-data /etc/group; then
    user_group="root:www-data"
elif grep -q apache2 /etc/group; then
    user_group="root:apache2"
elif grep -q apache /etc/group; then
    user_group="root:apache"
else
    echo "user:group error"
    exit 1
fi

# Red Hat with SCL uses httpd24-httpd.service, Fedora
# uses httpd24.service, Debian uses apache2.service
services=$(systemctl list-units --type=service 2>/dev/null)
if echo ${services} | grep -q httpd24-httpd.service; then
    service_name="httpd24-httpd.service"
elif echo ${services} | grep -q httpd24.service; then
    service_name="httpd24.service"
elif echo ${services} | grep -q apache2.service; then
    service_name="apache2.service"
else
    echo "service name error"
    exit 1
fi

echo "Ownership: ${user_group}"
echo "Service: ${service_name}"

if [[ $(id -u) != "0" ]]; then
    echo "You must be root to update the html"
    exit 1
fi

if [ ! -d "${www_directory}" ]; then
    echo "Unable to locate website directory"
    exit 1
fi

echo "Copying files"
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

echo "Setting ownership"
chown "${user_group}" "${www_directory}"
chown "${user_group}" "${www_directory}"/*

echo "Setting directory permissions"
IFS= find "${www_directory}" -maxdepth 1 -type d -print | while read -r dir
do
    chmod u=rwx,g=rx,o= "${dir}"
done

echo "Setting file permissions"
IFS= find "${www_directory}" -maxdepth 1 -type f -print | while read -r file
do
    if file -b "${file}" | grep -q -E 'executable|script';
    then
        chmod u=rwx,g=rx,o= "${file}"
    else
        chmod u=rw,g=r,o= "${file}"
    fi
done

echo "Setting zip filetimes"
# This part is the update-zip.sh script
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
