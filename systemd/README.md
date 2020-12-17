### Systemd services

Most of the world has moved to Systemd for init and job scheduling. Systemd-systems include Red Hat, CentOS, Debian and Ubuntu. This section of the website holds Systemd scripts in place of Cron jobs.

Cron jobs had a few drawbacks. The first was the lack of a "machine account". Lack of a machine account meant we had to tie a job to a user, like a backup job running for a user rather than a machine. The second is the difficulties to test/run a Cron job "right now" for testing. The third is lack of logging. /var/log/syslog shows a begin/end for a script identified by a session, but nothing else. Syslog does not provide a script name or messages from the script.

The warez in this section of the website need to be downloaded and updated manually. A Git clone brings in everything, but all we need are a few scripts. Git 2.19 would allow us to clone just Systemd, but the web server has Git 1.8. Also see https://stackoverflow.com/a/52269934.

The warez in this section of the website are held in root's home directory at `$HOME/backup-scripts`. The `backup-scripts` does NOT include the actual backup script because passwords are present. The actual backup scripts are located in `$HOME/backup-scripts`.

### Install.sh

The install.sh script installs the warez. It should be run as root.

```
cd backup-scripts
./install.sh
```

You should re-run `install.sh` to re-install the scripts if they change. See `update.sh` below.

### Update.sh

The artifacts in this section of the website need to be downloaded to the webserver and updated on occassion. Just run `update.sh` to perform the manual download and update.

```
cd backup-scripts
./update.sh
./install.sh
```

You should re-run `install.sh` to re-install the scripts if they change.

### Bitvise-backup

The bitvise-backup script runs the Bitvise backup. The warez include a Systemd service, timer and backup script. The `bitvise-backup` script is placed at `/usr/sbin/bitvise-backup`. The script includes a password so it is clamped down. Owner is `root:root`, and permissions are `u:rwx,g:rx,o:`.

The bitvise-backup script runs at 4:00 AM each night. The script performs a full backup every 3 months. Otherwise the script performs a differential backup.

### Gdrive-backup

The gdrive-backup script runs the Gdrive backup. The warez include a Systemd service, timer and backup script. The `gdrive-backup` script is placed at `/usr/sbin/gdrive-backup`. The script includes a secret token so it is clamped down. Owner is `root:root`, and permissions are `u:rwx,g:rx,o:`.

The gdrive-backup script runs at 5:00 AM each night. The script performs a full backup every 3 months. Otherwise the script performs a differential backup.

### Backup status

You can check the status of the services and times with `systemctl`. The timer should be active, and the service should be inactive. The service will switch to active once triggered by the timer.

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

You can view messages produced by the scripts using `journalctl`.

```
# journalctl -xe | grep -E 'gdrive|bitvise'
Dec 17 04:57:46 ftpit systemd[1]: Started Run bitvise-backup.service once a day.
-- Subject: Unit bitvise-backup.timer has finished start-up
-- Unit bitvise-backup.timer has finished starting up.
Dec 17 05:46:44 ftpit systemd[1]: Started Run gdrive-backup.service once a day.
-- Subject: Unit gdrive-backup.timer has finished start-up
-- Unit gdrive-backup.timer has finished starting up.
```