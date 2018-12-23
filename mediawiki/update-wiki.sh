#!/usr/bin/env bash

# update-wiki.sh performs maintenance on the website's wiki installation.
# The script does four things, give or take. First it updates GitHub
# based components in skins/ and extensions/. Second, it {re}sets
# permissions on some files and folders, including logging files
# in /var/log/. Third, it runs MediaWiki's update.php. Fourth, it
# restarts the MySQL and Apache services.
#
# update.php is important and it must be run anytime a change occurs.
#
# We should probably schedule this script as a cron job.

# Important variables
WIKI_DIR="/var/www/html/w"
WIKI_REL=REL1_31
LOG_DIR="/var/log"

THIS_DIR=$(pwd)
function finish {
    cd "$THIS_DIR"
}
trap finish EXIT

# Privileges?
if [[ ($(id -u) != "0") ]]; then
    echo "You must be root to update the wiki"
    [[ "$0" = "$BASH_SOURCE" ]] && exit 0 || return 0
fi

# This finds directories check'd out from Git and updates them.
# It works surprisingly well. There has only been a couple of
# minor problems.
for dir in $(find "$WIKI_DIR/skins" -name '.git'); do
    cd "$dir/.."
    echo "Updating ${dir::-4}"
    git reset --hard HEAD && git pull
    git checkout -f "$WIKI_REL"
done

for dir in $(find "$WIKI_DIR/extensions" -name '.git'); do
    cd "$dir/.."
    echo "Updating ${dir::-4}"
    git reset --hard HEAD && git pull
    git checkout -f "$WIKI_REL"
done

# Remove all test frameworks
for dir in $(find "$WIKI_DIR" -iname 'test*'); do
    rm -rf "$dir" 2>/dev/null
done

# Fix this permission
if [[ -f "$WIKI_DIR/extensions/SyntaxHighlight/pygments/pygmentize" ]]; then
    chmod ug+x "$WIKI_DIR/extensions/SyntaxHighlight/pygments/pygmentize"
fi

# Set proper ownership permissions. This is a required step after unpacking a
# new MediaWiki or cloning a new Skin or Extension. The permissions are never
# correct.
echo "Fixing MediaWiki permissions"
chown -R root:apache "$WIKI_DIR/"
chmod -R o-rwx "$WIKI_DIR/"

# Images/ must be writable by group
echo "Fixing MediaWiki images/ permissions"
for dir in $(find "$WIKI_DIR/images" -type d 2>/dev/null); do
    chmod ug+rwx "$dir"
    chmod o-rwx  "$dir"
done
for file in $(find "$WIKI_DIR/images" -type f 2>/dev/null); do
    chmod ug+rw "$file"
    chmod ug-x  "$file"
    chmod o-rwx "$file"
done

echo "Fixing Apache logging permissions"
for dir in $(find "$LOG_DIR" -type d -name 'httpd*' 2>/dev/null); do
    if [[ ! -d "$dir" ]]; then continue; fi
    chown root:apache "$dir"
    chmod ug+rwx "$dir"
    chmod o-rwx  "$dir"
done
for file in $(find "$LOG_DIR/httpd" -type f -name '*log*' 2>/dev/null); do
    if [[ ! -f "$file" ]]; then continue; fi
    chown root:apache "$file"
    chmod ug+rw "$file"
    chmod ug-x  "$file"
    chmod o-rwx "$file"
done
for file in $(find "$LOG_DIR/httpd24" -type f -name '*log*' 2>/dev/null); do
    if [[ ! -f "$file" ]]; then continue; fi
    chown root:apache "$file"
    chmod ug+rw "$file"
    chmod ug-x  "$file"
    chmod o-rwx "$file"
done

echo "Fixing MariaDB logging permissions"
chown mysql:mysql "$LOG_DIR/mariadb"
for file in $(find "$LOG_DIR/mariadb" -type f -name '*log*' 2>/dev/null); do
    if [[ ! -f "$file" ]]; then continue; fi
    chown mysql:mysql "$file"
    chmod ug+rw "$file"
    chmod ug-x  "$file"
    chmod o-rwx "$file"
done

# Cleanup backup files
echo "Cleaning backup files"
find /var/www/ -name '*~' -exec rm {} \;
find /opt -name '*~' -exec rm {} \;
find /etc -name '*~' -exec rm {} \;

# Make sure MySQL is running. It is a chronic source of problems because
# the Linux OOM killer targets mysqld.
echo "Restarting MySQL"
# systemctl restart mariadb.service &>/dev/null
systemctl start mariadb.service

# Always run update script per https://www.mediawiki.org/wiki/Manual:Update.php
echo "Running update.php"
/opt/rh/rh-php71/root/usr/bin/php "$WIKI_DIR/maintenance/update.php" --quick 2>&1

echo "Restarting Apache service"
if ! systemctl restart httpd24-httpd.service 2>&1; then
    echo "Restart failed. Sleeping for 3"
    sleep 3
    echo "Restarting Apache service"
    systemctl stop httpd24-httpd.service 2>&1
    systemctl start httpd24-httpd.service 2>&1
fi
