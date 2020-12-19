#!/usr/bin/env bash

# Use this script to move website artifacts, like *.html
# and *.css files, to the web server directory.

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

count=$(ls -1 cryptopp*.zip 2>/dev/null | wc -l)
if [ "${count}" -ne 0 ]; then
    mv cryptopp*.zip "${www_directory}"
fi

count=$(ls -1 cryptopp*.sig 2>/dev/null | wc -l)
if [ "${count}" -ne 0 ]; then
    mv cryptopp*.sig "${www_directory}"
fi

# Ownership
chown root:apache "${www_directory}"/*

# And permissions
IFS= find "${www_directory}" -maxdepth 1 -type d -print | while read -r dir
do
    chmod u=rwx,g=rx,o= "${dir}"
done

# And more permissions
IFS= find "${www_directory}" -maxdepth 1 -type f -print | while read -r file
do
    chmod u=rw,g=r,o= "${file}"
done

exit 0
