# Systemd services

Most of the world has moved to Systemd for init and job scheduling, including Red Hat, CentOS, Debian and Ubuntu. This section of the website holds Systemd scripts in place of Cron jobs. The scripts update the system and perform backups on a nightly basis.

Cron jobs had a few drawbacks. The first problem was the lack of a "machine account". Lack of a machine account meant we had to tie a job to a user, like a backup job running for a user rather than a machine. Locating all Cron jobs for all users is problematic. The second problem is running a Cron job "right now" for testing. There's no simple way to do it. The third problem is lack of logging. /var/log/syslog shows a begin/end for a script identified by a session, but nothing else. Syslog does not provide a script name or messages from the script.

The warez in this section of the website are copied in root's home directory at `$HOME/backup-scripts`. The GitHub does NOT include the actual backup script because passwords are present. The actual backup scripts are located in `$HOME/backup-scripts`.

The warez in this section of the website need to be downloaded and updated manually. A Git clone brings in everything, but all we need are a few scripts. Git 2.19 would allow us to clone just Systemd, but the web server has Git 1.8. Also see https://stackoverflow.com/a/52269934.

## Note Well

This GitHub lacks `/usr/sbin/bitvise-backup` and `/usr/sbin/gdrive-backup`. The files are the actual backup scripts with credentials.

The scripts are not located in this GitHub. The scripts are available in root's home directory and on the filesystem in `/sbin`.

## Update.sh

The artifacts in this section of the website need to be downloaded to the web server and updated on occassion. Just run `update.sh` to perform the initial download and manual update.

```
cd backup-scripts
wget -O update.sh https://github.com/weidai11/website/blob/master/systemd/update.sh
chmod +x update.sh
./update.sh
./install.sh
```

You should re-run `install.sh` to re-install the scripts if they change.

## Install.sh

The install.sh script installs the warez. It should be run as root.

```
cd backup-scripts
./install.sh
```

You should re-run `install.sh` to re-install the scripts if they change. See `update.sh` below.

## System-update

The system-update script updates the system once a day without user prompts. The script applies all updates, and not just security updates. The warez includes a Systemd service, timer and script. The `system-update` script is placed at `/usr/sbin/system-update.sh`.

The system-update script runs at 4:00 AM each night. The script reboots the machine as required.

## Bitvise-backup

The bitvise-backup script runs the Bitvise backup. The warez includes a Systemd service, timer and backup script. The bitvise-backup script runs at 5:00 AM each night. The script performs a full backup every 3 months. Otherwise the script performs an incremental backup.

The `bitvise-backup` script is placed at `/usr/sbin/bitvise-backup`. The script includes a password so it is clamped down. Owner is `root:root`, and permissions are `u:rwx,g:rx,o:`.

## Gdrive-backup

The gdrive-backup script runs the Gdrive backup. The warez includes a Systemd service, timer and backup script. The gdrive-backup script runs at 5:30 AM each night. The script performs a full backup every 3 months. Otherwise the script performs an incremental backup.

The `gdrive-backup` script is placed at `/usr/sbin/gdrive-backup`. The script includes a secret token so it is clamped down. Owner is `root:root`, and permissions are `u:rwx,g:rx,o:`.

## Systemctl status

You can check the status of the services and timers with `systemctl`. The timer should be active, and the service should be inactive. The service will switch to active once triggered by the timer.

```
# systemctl status bitvise-backup.timer
● bitvise-backup.timer - Run bitvise-backup.service once a day
   Loaded: loaded (/etc/systemd/system/bitvise-backup.timer; enabled; vendor preset: disabled)
   Active: active (waiting) since Thu 2020-12-17 04:57:46 EST; 56min ago
     Docs: https://github.com/weidai11/website/systemd

# systemctl status bitvise-backup.service
● bitvise-backup.service - Run bitvise-backup.service once a day
   Loaded: loaded (/etc/systemd/system/bitvise-backup.service; static; vendor preset: disabled)
   Active: inactive (dead)
     Docs: https://github.com/weidai11/website/systemd
```

A successful incremental backup looks like the following.

```
# systemctl status bitvise-backup.service
● bitvise-backup.service - Run bitvise-backup.service once a day
     Loaded: loaded (/etc/systemd/system/bitvise-backup.service; static; vendor preset: enabled)
     Active: inactive (dead) since Wed 2021-03-31 02:33:48 UTC; 56s ago
TriggeredBy: ● bitvise-backup.timer
       Docs: https://github.com/weidai11/website/systemd
    Process: 3684 ExecStart=/usr/sbin/bitvise-backup (code=exited, status=0/SUCCESS)
   Main PID: 3684 (code=exited, status=0/SUCCESS)

Mar 31 02:33:48 localhost bitvise-backup[3788]: ChangedFiles 27
Mar 31 02:33:48 localhost bitvise-backup[3788]: ChangedFileSize 60893049 (58.1 MB)
Mar 31 02:33:48 localhost bitvise-backup[3788]: ChangedDeltaSize 0 (0 bytes)
Mar 31 02:33:48 localhost bitvise-backup[3788]: DeltaEntries 51
Mar 31 02:33:48 localhost bitvise-backup[3788]: RawDeltaSize 1374941 (1.31 MB)
Mar 31 02:33:48 localhost bitvise-backup[3788]: TotalDestinationSizeChange 240279 (235 KB)
Mar 31 02:33:48 localhost bitvise-backup[3788]: Errors 0
Mar 31 02:33:48 localhost bitvise-backup[3788]: -------------------------------------------------
Mar 31 02:33:48 localhost systemd[1]: bitvise-backup.service: Succeeded.
Mar 31 02:33:48 localhost systemd[1]: Finished Run bitvise-backup.service once a day.
```
