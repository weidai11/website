#!/usr/bin/env bash

# update-wiki.sh performs maintenance on the Mediawiki installation.
# The script does four things, give or take. First it updates GitHub
# based components in skins/ and extensions/. Second, it {re}sets
# ownership and permissions on Mediawiki files and folders. Third,
# it then restarts the the MySQL and Apache service. Finally, it runs
# MediaWiki's update.php. update.php is important and it must be run
# anytime a change occurs.
#
# We have to use the safer form of the find command because some skins
# and extensions use whitespace in some of their file names.
#
# The script is located in the wiki directory, which is /var/www/html/w.
# We should probably schedule this script as a cron job or systemd unit.
#
# This script takes about 5 minutes to run.

# Important variables
html_dir="/var/www"
wiki_dir="/var/www/html/w"
wiki_rel=REL1_35
php_bin=/usr/bin/php

# Pretty print
red_color='\033[0;31m'
cyan_color='\033[0;36m'
green_color='\033[0;32m'
no_color='\033[0m'

# Privileges? Exit 0 to keep things moving along
# Errors will be printed to the terminal
if [[ $(id -u) != "0" ]]; then
    echo "You must be root to update the wiki"
    exit 0
fi

if [[ ! -d "${wiki_dir}" ]]; then
    echo "wiki_dir is not valid."
    exit 1
fi

if [[ ! -f "${php_bin}" ]]; then
    echo "php_bin is not valid."
    exit 1
fi

# Red Hat uses root:apache, Debian uses root:www-data
if grep -q www-data /etc/group; then
    apache_owner="root:www-data"
elif grep -q apache2 /etc/group; then
    apache_owner="root:apache2"
elif grep -q apache /etc/group; then
    apache_owner="root:apache"
else
    echo "user:group name error"
    exit 1
fi

# Red Hat with SCL uses httpd24-httpd.service, Fedora
# uses httpd24.service, Debian uses apache2.service
services=$(systemctl list-units --type=service 2>/dev/null)
if echo "${services}" | grep -q httpd24-httpd.service; then
    apache_service="httpd24-httpd.service"
elif echo "${services}" | grep -q httpd24.service; then
    apache_service="httpd24.service"
elif echo "${services}" | grep -q apache2.service; then
    apache_service="apache2.service"
else
    echo "Apache service name error"
    exit 1
fi

# Red Hat with SCL uses mariadb.service,
# Debian uses mysql.service
services=$(systemctl list-units --type=service 2>/dev/null)
if echo "${services}" | grep -q mariadb.service; then
    mysql_service="mariadb.service"
elif echo "${services}" | grep -q mysql.service; then
    mysql_service="mysql.service"
else
    echo "MySQL service name error"
    exit 1
fi

echo -e "Apache ownership: ${cyan_color}${apache_owner}${no_color}"
echo -e "Apache service: ${cyan_color}${apache_service}${no_color}"
echo -e "MySQL service: ${cyan_color}${mysql_service}${no_color}"

# Composer needs to be run from Wiki directory.
cd "${wiki_dir}" || exit 1

# This finds directories check'd out from Git and updates them.
# It works surprisingly well. There have only been a couple of
# minor problems.
IFS= find "${wiki_dir}/skins" -type d -name '.git' -print | while read -r dir
do
    # Strip '.git'
    dir="$(dirname  ${dir})"
    skin="$(basename ${dir})"
    echo -e "${green_color}Updating skin ${skin}${no_color}"

    # Run in a subshell
    (
        echo "Entering ${dir}"
        cd "${dir}" || continue

        if git branch -a 2>/dev/null | grep -q "${wiki_rel}"
        then
            # Some GitHubs have both branch and tag with same name.
            # Hence the 'git tag -d'.
            git fetch origin && git reset --hard "origin/${wiki_rel}" && \
              git tag -d "${wiki_rel}" 2>/dev/null && \
              git checkout -f "${wiki_rel}" && git clean -xdf
        else
            # Some GitHubs don't follow Mediawiki conventions.
            # They lack a branch like REL1_32, REL1_35, etc.
            git fetch origin && git reset --hard origin && git clean -xdf
        fi

        # Cleanup
        git fetch --prune >/dev/null 2>&1
    )
done

IFS= find "${wiki_dir}/extensions" -type d -name '.git' -print | while read -r dir
do
    # Strip '.git'
    dir="$(dirname  ${dir})"
    extension="$(basename ${dir})"
    echo -e "${green_color}Updating extension ${extension}${no_color}"

    # Run in a subshell
    (
        echo "Entering ${dir}"
        cd "${dir}" || continue

        if git branch -a 2>/dev/null | grep -q "${wiki_rel}"
        then
            # Some GitHubs have both branch and tag with same name.
            # Hence the 'git tag -d'.
            git fetch origin && git reset --hard "origin/${wiki_rel}" && \
              git tag -d "${wiki_rel}" 2>/dev/null && \
              git checkout -f "${wiki_rel}" && git clean -xdf
        else
            # Some GitHubs don't follow Mediawiki conventions.
            # They lack a branch like REL1_32, REL1_35, etc.
            git fetch origin && git reset --hard origin && git clean -xdf
        fi

        # Cleanup
        git fetch --prune >/dev/null 2>&1
    )
done

# If composer is present, then update files
echo -e "${green_color}Updating dependencies via Composer${no_color}"
if command -v composer 1>/dev/null 2>&1
then
    if composer update --no-dev; then
        echo -e "${green_color}Updated dependencies via Composer${no_color}"
    else
        echo -e "${red_color}Failed to update dependencies via Composer${no_color}"
    fi
else
    echo -e "${red_color}Skipping... Composer not installed${no_color}"
fi

# Set ownership of the Webserver and Mediawiki files.
# The git checkout may upset ownership.
echo -e "${green_color}Setting Webserver ownership${no_color}"
chown -R ${apache_owner} "${html_dir}"

# Remove all developer gear in production. We are not PHP developers.
# Don't use a wildcard on 'dev'. It matches 'Device' and breaks MobileFrontEnd.
echo -e "${green_color}Removing Mediawiki dev gear${no_color}"
IFS= find "${wiki_dir}" -type d -iname 'dev' -print | while read -r dir
do
    rm -rf "$dir" 2>/dev/null
done

# Remove all demos in production. We are not PHP developers.
echo -e "${green_color}Removing Mediawiki demo gear${no_color}"
IFS= find "${wiki_dir}" -type d -iname 'demos*' -print | while read -r dir
do
    rm -rf "$dir" 2>/dev/null
done

# Remove all test frameworks in production. We are not PHP developers.
echo -e "${green_color}Removing Mediawiki test gear${no_color}"
IFS= find "${wiki_dir}" -type d -iname 'test*' -print | while read -r dir
do
    rm -rf "$dir" 2>/dev/null
done

# Remove all benchmark frameworks in production. We are not PHP developers.
echo -e "${green_color}Removing Mediawiki benchmark gear${no_color}"
IFS= find "${wiki_dir}" -type d -iname 'benchmark*' -print | while read -r dir
do
    rm -rf "$dir" 2>/dev/null
done

# Remove all docs in production. No need to back them up.
echo -e "${green_color}Removing Mediawiki documentation${no_color}"
IFS= find "${wiki_dir}" -type d -iname 'doc*' -print | while read -r dir
do
    rm -rf "$dir" 2>/dev/null
done

# Remove all screenshots in production. No need to back them up.
echo -e "${green_color}Removing Mediawiki screenshots${no_color}"
IFS= find "${wiki_dir}" -type d -iname 'screenshot*' -print | while read -r dir
do
    rm -rf "$dir" 2>/dev/null
done

echo -e "${green_color}Creating MediaWiki sitemap${no_color}"
if [[ -f "${wiki_dir}/create-sitemap.sh" ]]; then
    rm -rf "${wiki_dir}/sitemap"
    bash "${wiki_dir}/create-sitemap.sh" 1>/dev/null
fi

# Set proper ownership and permissions. This is required after unpacking a
# new MediaWiki or cloning a Skin or Extension. The permissions are never
# correct. Executable files will be missing +x, and images will have +x.

# We would like to skip images/ here, but find and -prune is too sideways.
# images/ gets different permissions. find's -prune does not seem to
# work as expected.
echo -e "${green_color}Setting MediaWiki permissions${no_color}"
IFS= find "${wiki_dir}" -type d -print | while read -r dir
do
    chmod u=rwx,g=rx,o= "$dir"
done
IFS= find "${wiki_dir}" -type f -print | while read -r file
do
    chmod u=rw,g=r,o= "$file"
done

# images/ must be writable by Apache. This is the directory where images
# are saved and thumbnails are created. It is also the upload directory.
echo -e "${green_color}Setting MediaWiki images permissions${no_color}"
IFS= find "${wiki_dir}/images" -type d | while read -r dir
do
    chmod ug=rwx,o= "$dir"
done
IFS= find "${wiki_dir}/images" -type f | while read -r file
do
    chmod ug=rw,o= "$file"
done

# Make Python, PHP and friends executable
echo -e "${green_color}Setting Executable file permissions${no_color}"
IFS= find "${wiki_dir}" -type f -print | while read -r file
do
    if file -b "${file}" | grep -q -E 'executable|script';
    then
        chmod u=rwx,g=rx,o= "${file}"
    else
        chmod u=rw,g=r,o= "${file}"
    fi
done

# Cleanup backup files
echo -e "${green_color}Cleaning backup files${no_color}"
find /var/www -name '*~' -exec rm {} \;
find /opt -name '*~' -exec rm {} \;
find /etc -name '*~' -exec rm {} \;

# Make sure MySQL is running for update.php. It is a chronic
# problem because the Linux OOM killer targets mysqld.
echo -e "${green_color}Restarting MySQL service${no_color}"
if ! systemctl restart ${mysql_service}; then
    echo "Restart failed. Sleeping for 3 seconds"
    sleep 3
    echo "Restarting Apache service"
    systemctl stop ${mysql_service} 2>/dev/null
    systemctl start ${mysql_service}
fi

# Always run update script per https://www.mediawiki.org/wiki/Manual:Update.php
echo -e "${green_color}Running update.php${no_color}"
"${php_bin}" "${wiki_dir}/maintenance/update.php" --quick --server="https://www.cryptopp.com/wiki" | head -n 1

echo -e "${green_color}Restarting Apache service${no_color}"
if ! systemctl restart ${apache_service}; then
    echo "Restart failed. Sleeping for 3 seconds"
    sleep 3
    echo "Restarting Apache service"
    systemctl stop ${apache_service} 2>/dev/null
    systemctl start ${apache_service}
fi

exit 0
