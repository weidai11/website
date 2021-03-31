#!/usr/bin/env bash

export PATH=/sbin:/usr/sbin:/bin:/usr/bin
export DEBIAN_FRONTEND=noninteractive

echo "Updating package list"
apt-get -y autoclean &>/dev/null
apt-get update &>/dev/null

# Ubuntu makes it a pain in the ass to remove old kernels
# https://help.ubuntu.com/community/RemoveOldKernels
if true
then
    apt-mark auto '^linux-.*-4.*(-generic)?$' &>/dev/null
    apt-mark auto '^linux-.*-5.*(-generic)?$' &>/dev/null
fi

if true
then
    echo "Purging old packages"
    apt autoremove --purge &>/dev/null
fi

# If no packages are upgradable, then the message is "Listing... Done".
# Otherwise a package name is listed as upgradable.
needs_update=$(apt list --upgradable 2>/dev/null | grep -c -i -v 'Listing')

# Only update and reboot if packages are available
if [[ "$needs_update" -gt 0 ]]
then

    apt-get upgrade -y &>/dev/null
    ret_val=$?

    if [[ "$ret_val" -eq 0 ]]
    then
        echo "Upgraded system"
    else
        echo "Failed to upgrade system, error $ret_val"
        exit "$ret_val"
    fi

    needs_reboot=1
else
    echo "No system updates"
fi

if [[ -f /var/run/reboot-required ]]
then
    needs_reboot=1
fi

if [[ "$needs_reboot" -eq 1 ]]
then
    echo "Scheduling reboot in 10 minutes"
    # shutdown -r +10
    systemd-run --on-active=10m shutdown -r now
else
    echo "No reboot required"
fi

exit 0
