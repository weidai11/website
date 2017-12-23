#!/usr/bin/env bash

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
    for txx in $(find "$PWD" -type d -name 'test*'); do
	rm -rf "$txx"
    done
done

for dir in $(find "$WIKI_DIR/extensions" -name '.git'); do
    cd "$dir/.."
    echo "Updating ${dir::-4}"
    git reset --hard HEAD && git pull
    for txx in $(find "$PWD" -type d -name 'test*'); do
        rm -rf "$txx"
    done
done

if [[ -f "$WIKI_DIR/extensions/SyntaxHighlight_GeSHi/pygments/pygmentize" ]]; then
    chmod ug+x "$WIKI_DIR/extensions/SyntaxHighlight_GeSHi/pygments/pygmentize"
fi

# Set proper ownership permissions. This is a required step after unpacking a new
# MediaWiki or cloning a new Skin or Extension. The permissions are never correct.
chown -R root:apache "$WIKI_DIR/"
chmod -R o-rwx "$WIKI_DIR/"

# Cleanup backup files
find /var/www/ -name '*~' -exec rm {} \;

# Fix Apache logging permissions
for dir in $(find "$LOG_DIR" -type d -name 'httpd*'); do
    chown -R root:apache "$dir"
    chmod -R ug+rwx "$dir"
    chmod -R o-rwx  "$dir"
done

for file in $(find "$LOG_DIR" -type f -name '*log*'); do
    chown root:apache "$file"
    chmod ug+rw "$file"
    chmod ug-x  "$file"
    chmod o-rwx "$file"
done

# Always run update script per https://www.mediawiki.org/wiki/Manual:Update.php
php "$WIKI_DIR/maintenance/update.php" --quick

echo "Restarting Apache service"
systemctl restart httpd24-httpd.service

cd "$TOP_DIR"
