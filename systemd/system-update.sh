#!/usr/bin/env bash

# This script updates the system once a day without user prompts.
# If required the script reboots the machine. Also see
# https://github.com/weidai11/website/tree/master/systemd

export PATH=/sbin:/usr/sbin:/bin:/usr/bin

echo "Updating package list"
yum clean all &>/dev/null
yum check-update &>/dev/null

if true
then
    echo "Purging old packages"
    yum -y autoremove &>/dev/null
fi

# If no packages are upgradable, then the message is "Last metadata expiration check ...".
# Otherwise a package name is listed as upgradable.
needs_update=$(yum check-update 2>/dev/null | grep -c -v -E '^Last metadata|^Fedora')

# Only update and reboot if packages are available
if [[ "$needs_update" -gt 0 ]]
then
    echo "Upgrades are available"
    yum -y update &>/dev/null
    ret_val=$?

    if [[ ("$ret_val" -eq 0) || ("$ret_val" -eq 100) ]]
    then
        echo "Upgraded system"
    else
        echo "Failed to upgrade system, error $ret_val"
        exit "$ret_val"
    fi
else
    echo "No system updates"
fi

# needs-restarting misses an updated kernel
# Check /lib/modules for an updated kernel
reboot_required=0

if [[ $(needs-restarting -r &>/dev/null) -eq 1 ]]
then
    reboot_required=1
fi

if [[ "$reboot_required" -eq 1 ]]
then
    echo "Scheduling reboot in 5 minutes"
    # shutdown -r +5
    systemd-run --on-active=5m shutdown -r now
else
    echo "No reboot required"
fi

exit 0
