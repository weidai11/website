#!/usr/bin/env bash

# update-wiki.sh performs maintenance on the website's wiki installation.
# The script does three things, give or take. First it updates GitHub
# based components in skins/ and extensions/. Second, it {re}sets
# ownership and permissions on some files and folders, including logging
# files in /var/log. Third, it runs MediaWiki's update.php and then restarts
# the Apache service. update.php is important and it must be run anytime
# a change occurs.
#
# We have to use the safer form of the find command because some skins and
# extensions use whitespace in some of their file names.
#
# The script is located in the wiki directory, which is /var/www/html/w.
# We should probably schedule this script as a cron job or systemd unit.
#
# This script takes about 10 minutes to run.

# Important variables
WIKI_DIR="/var/www/html/w"
WIKI_REL=REL1_35
PHP_BIN=/opt/rh/rh-php73/root/usr/bin/php
LOG_DIR="/var/log"

# Privileges? Exit 0 to keep things moving along
# Errors will be printed to the terminal
if [[ ($(id -u) != "0") ]]; then
    echo "You must be root to update the wiki"
    exit 0
fi

if [[ ! -d "${WIKI_DIR}" ]]; then
    echo "WIKI_DIR is not valid."
    exit 1
fi

if [[ ! -f "${PHP_BIN}" ]]; then
    echo "PHP_BIN is not valid."
    exit 1
fi

# This finds directories check'd out from Git and updates them. 
# It works surprisingly well. There have only been a couple of
# minor problems.
IFS= find "$WIKI_DIR/skins" -type d -name '.git' -print | while read -r dir
do
    cd "$dir/.."
    echo "Updating ${dir::-4}"
    git reset --hard HEAD && git pull && \
      git checkout -f "$WIKI_REL" && git pull
done

IFS= find "$WIKI_DIR/extensions" -type d -name '.git' -print | while read -r dir
do
    cd "$dir/.."
    echo "Updating ${dir::-4}"
    git reset --hard HEAD && git pull && \
      git checkout -f "$WIKI_REL" && git pull
done

# Remove all developer gear in production. We are not PHP developers.
# Don't use a wildcard on 'dev'. It matches 'Device' and breaks MobileFrontEnd.
IFS= find "$WIKI_DIR" -type d -iname 'dev' -print | while read -r dir
do
    rm -rf "$dir" 2>/dev/null
done

# Remove all test frameworks in production. We are not PHP developers.
IFS= find "$WIKI_DIR" -type d -iname 'test*' -print | while read -r dir
do
    rm -rf "$dir" 2>/dev/null
done

# Remove all benchmark frameworks in production. We are not PHP developers.
IFS= find "$WIKI_DIR" -type d -iname 'benchmark*' -print | while read -r dir
do
    rm -rf "$dir" 2>/dev/null
done

# Remove all docs in production. No need to back them up.
IFS= find "$WIKI_DIR" -type d -iname 'doc*' -print | while read -r dir
do
    rm -rf "$dir" 2>/dev/null
done

# Remove all screenshots in production. No need to back them up.
IFS= find "$WIKI_DIR" -type d -iname 'screenshot*' -print | while read -r dir
do
    rm -rf "$dir" 2>/dev/null
done

echo "Creating MediaWiki sitemap"
if [[ -f "$WIKI_DIR/create-sitemap.sh" ]]; then
    rm -rf "$WIKI_DIR/sitemap"
    bash "$WIKI_DIR/create-sitemap.sh" 1>/dev/null
fi

# Set proper ownership and permissions. This is required after unpacking a
# new MediaWiki or cloning a Skin or Extension. The permissions are never
# correct. Executable files will be missing +x, and images will have +x.

echo "Setting MediaWiki permissions"
chown -R root:apache "$WIKI_DIR/"
IFS= find "$WIKI_DIR" -type d -print | while read -r dir
do
    chmod u=rwx,g=rx,o= "$dir"
done
IFS= find "$WIKI_DIR" -type f -print | while read -r file
do
    chmod u=rw,g=r,o= "$file"
done

echo "Setting MediaWiki images/ permissions"
IFS= find "$WIKI_DIR/images" -type d | while read -r dir
do
    chmod ug=rwx,o= "$dir"
done
IFS= find "$WIKI_DIR/images" -type f | while read -r file
do
    chmod ug=rw,o= "$file"
done

# Make Python and PHP executable
echo "Setting file permissions"
IFS= find "$WIKI_DIR" -type f -print | while read -r file
do
    if file -b "${file}" | grep -q -E 'executable|script';
    then
        chmod u=rwx,g=rx,o= "${file}"
    else
        chmod u=rw,g=r,o= "${file}"
    fi
done

echo "Setting Apache session permissions"
if [[ -d "/var/lib/pear" ]]
then
    chown -R apache:apache "/var/lib/pear"
    IFS= find "/var/lib/pear" -type d | while read -r dir
    do
        chmod ug=rwx,o= "$dir"
    done
    IFS= find "/var/lib/pear" -type f | while read -r file
    do
        chmod ug=rw,o= "$file"
    done
fi

if [[ -d "/var/lib/php" ]]
then
    chown -R apache:apache "/var/lib/php"
    IFS= find "/var/lib/php" -type d | while read -r dir
    do
        chmod ug=rwx,o= "$dir"
    done
    IFS= find "/var/lib/php" -type f | while read -r file
    do
        chmod ug=rw,o= "$file"
    done
fi

echo "Setting Apache logging permissions"
IFS= find "$LOG_DIR" -type d -name 'httpd*' | while read -r dir
do
    chown -R root:apache "$dir"
    chmod ug=rwx,o= "$dir"
    IFS= find "$dir" -type f -name '*log*' | while read -r file
    do
        chmod ug=rw,o= "$file"
    done
done

echo "Setting MariaDB logging permissions"
chown -R mysql:mysql "$LOG_DIR/mariadb"
IFS= find "$LOG_DIR/mariadb" -type f -name '*log*' | while read -r file
do
    chown mysql:mysql "$file"
    chmod ug=rw,o= "$file"
done

# Make sure MySQL is running for update.php. It is a chronic
# source of problems because the Linux OOM killer targets mysqld.
echo "Restarting MySQL"
systemctl stop mariadb.service 2>/dev/null
systemctl start mariadb.service

# Always run update script per https://www.mediawiki.org/wiki/Manual:Update.php
echo "Running update.php"
"${PHP_BIN}" "$WIKI_DIR/maintenance/update.php" --quick --server="https://www.cryptopp.com/wiki"

echo "Restarting Apache service"
if ! systemctl restart httpd24-httpd.service; then
    echo "Restart failed. Sleeping for 3 seconds"
    sleep 3
    echo "Restarting Apache service"
    systemctl stop httpd24-httpd.service 2>/dev/null
    systemctl start httpd24-httpd.service
fi

# Cleanup backup files
echo "Cleaning backup files"
find /var/www -name '*~' -exec rm {} \;
find /opt -name '*~' -exec rm {} \;
find /etc -name '*~' -exec rm {} \;

exit 0
