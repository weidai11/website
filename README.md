This GitHub is used to backup important elements of the Crypto++ website, and provide centralized collection of admin notes and scripts for the vm and website.

Important elements of the Crypto++ website include ZIP files, signatures and release notes. They are located in the `html/` subdirectory and can be quickly restored. Duplicity is still available, but duplicity takes longer than a `scp -p *.html *.css *.png *.svg *.ico *.zip *.zip.sig cryptopp.com:`. Once the files are in your home directory, you can run `update-html.sh` to copy them to `/var/www/html` and set ownership and permissions.

Here are the subdirectories of this repo:

  * html - the website's static front-page files
  * install - how to setup and configure a VM like the webserver
  * restore - how to perform a restore using Duplicity
  * mediawiki - how to perform a Mediawiki upgrade, like MW 1.35 to 1.35.1
  * systemd - units and scripts used to backup the VM
  * letsencrypt - how to renew the webserver's TLS certificate
  * iptables - how to block misbehaving IP hosts

After an install or restore, you have to manually restore the full html tree. The full tree includes Doxygen documentation and Mediawiki software.

After an install or restore, you have to manually restore the Mediawiki database. The database is easy to import once you setup the Mediawili user and create the database.

After an install or restore, you have to manually configure backups using the files in `systemd/`. Just run `systemd/install.sh` to perform the action.

One important file is missing. `cryptopp.conf` is not available in this GitHub because it holds passwords and shared secrets. You must have a copy of it somewhere. It is one of those files that you should have an encrypted local copy somewhere, like on a local machine or in email.
