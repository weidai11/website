#!/usr/bin/env bash

# Use this script to move Doxygen documentation to the web server docs/ directory.
# On the local machine, run 'make docs' and then scp CryptoPPRef.zip to the server.
# The script will move and unpack CryptoPPRef.zip. The script sets ownership and
# permissions as required.

www_directory=/var/www/html

# This follows Crypto++ release number
ref_dir=ref840/

if [[ $(id -u) != "0" ]]; then
    echo "You must be root to update the docs"
    exit 1
fi

if [[ ! -f CryptoPPRef.zip ]]; then
    echo "CryptoPPRef.zip is missing"
    exit 1
fi

if [ ! -d "${www_directory}" ]; then
    echo "Unable to locate website directory"
    exit 1
fi

echo "Preparing files and directories"
mkdir -p "${www_directory}/docs"
mv CryptoPPRef.zip "${www_directory}/docs"
cd "${www_directory}/docs"

# Remove old link, add new link
rm -f ref
mkdir -p "${ref_dir}"
ln -s "${ref_dir}" ref

echo "Unpacking documentation"
unzip -aoq CryptoPPRef.zip -d .
mv CryptoPPRef.zip ref/

echo "Changing ownership"
chown -R root:apache "${www_directory}/docs/${ref_dir}"
chown root:apache ref/CryptoPPRef.zip

echo "Setting directory permissions"
IFS= find "${www_directory}/docs/${ref_dir}" -type d -print | while read -r dir
do
    chmod u=rwx,g=rx,o= "${dir}"
done

echo "Setting file permissions"
IFS= find "${www_directory}/docs/${ref_dir}" -type f -print | while read -r file
do
    if file -b "${file}" | grep -q -E 'executable|script';
    then
        chmod u=rwx,g=rx,o= "${file}"
    else
        chmod u=rw,g=r,o= "${file}"
    fi
done

echo "Restarting web server"
systemctl restart httpd24-httpd.service

exit 0
