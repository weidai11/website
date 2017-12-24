#!/usr/bin/env bash

# update-wiki.sh performs maintenance on the website's wiki installation.
# The script does three things, give or take. First it updates GitHub
# based components in skins/ and extensions/. Second, it {re}sets
# permissions on some files and folders, including logging files
# in /var/log. Third, it runs MediaWiki's update.php and then restarts
# the Apache service. update.php is important and it must be run anytime
# a change occurs.
#
# The script is located in the wiki directory, which is a subdirectory off
# /var/www/html/. We should probably schedule this script as a cron job.

# Important directories
WIKI_DIR="/var/www/html/w"
LOG_DIR="/var/log"
TOP_DIR=$(pwd)

# This finds directories check'd out from Git and updates them. 
# It works surprisingly well. There has only been a couple of
# minor problems.
for dir in $(find "$WIKI_DIR/skins" -name '.git'); do
    cd "$dir/.."
    echo "Updating ${dir::-4}"
    git reset --hard HEAD && git pull
done

for dir in $(find "$WIKI_DIR/extensions" -name '.git'); do
    cd "$dir/.."
    echo "Updating ${dir::-4}"
    git reset --hard HEAD && git pull
done

# Remove all test frameworks
for dir in $(find "$WIKI_DIR" -iname 'test*'); do
    rm -rf "$dir" 2>/dev/null
done

if [[ -f "$WIKI_DIR/extensions/SyntaxHighlight_GeSHi/pygments/pygmentize" ]]; then
    chmod ug+x "$WIKI_DIR/extensions/SyntaxHighlight_GeSHi/pygments/pygmentize"
fi

# Set proper ownership permissions. This is a required step after unpacking a new
# MediaWiki or cloning a new Skin or Extension. The permissions are never correct.
echo "Fixing MediaWiki permissions"
chown -R root:apache "$WIKI_DIR/"
chmod -R o-rwx "$WIKI_DIR/"

# Images/ must be writable by group
for dir in $(find "$WIKI_DIR/images" -type d); do
    chmod ug+rwx "$dir"
done
for file in $(find "$WIKI_DIR/images" -type f); do
    chmod ug+rw "$file"
done

# Fix Apache logging permissions
for dir in $(find "$LOG_DIR" -type d -name 'httpd*'); do
    chown root:apache "$dir"
    chmod ug+rwx "$dir"
    chmod o-rwx  "$dir"
done

for file in $(find "$LOG_DIR" -type f -name '*log*'); do
    chown root:apache "$file"
    chmod ug+rw "$file"
    chmod ug-x  "$file"
    chmod o-rwx "$file"
done

# Cleanup backup files
find /var/www/ -name '*~' -exec rm {} \;

# Always run update script per https://www.mediawiki.org/wiki/Manual:Update.php
php "$WIKI_DIR/maintenance/update.php" --quick

echo "Restarting Apache service"
systemctl restart httpd24-httpd.service

cd "$TOP_DIR"
