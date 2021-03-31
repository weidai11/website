#!/usr/bin/env bash

# Use this script to move Doxygen documentation to the web server docs/ directory.
# On the local machine, run 'make docs' and then scp CryptoPPRef.zip to the server.
# The script will move and unpack CryptoPPRef.zip. The script sets ownership and
# permissions as required.

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

# This follows Crypto++ release number
ref_dir=ref850/

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
# rm -f ref
unlink ref/ 2>/dev/null
mkdir -p "${ref_dir}"
ln -s "${ref_dir}" ref

echo "Unpacking documentation"
unzip -aoq CryptoPPRef.zip -d .
mv CryptoPPRef.zip ref/

echo "Changing ownership"
chown -R "${user_group}" "${www_directory}/docs/${ref_dir}"
chown "${user_group}" ref/CryptoPPRef.zip

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
systemctl restart "${service_name}"

exit 0
