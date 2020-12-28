This GitHub is used to backup important elements of the Crypto++ website, and provide centralized collection of admin notes and scripts for the website.

Important elements of the Crypto++ website include ZIP files, signatures and release notes. They can be quickly restored if needed. Duplicity is still available, but duplicity takes longer than a `scp -p *.html *.css *.png *.ico *.zip *.zip.sig cryptopp.com:`. Once the files are in your home directory, you can run `update-html.sh` to copy them to `/var/www/html` and set ownership and permissions.

The admin notes and scripts document processes and procedures to administer the site. For example, installation of Red Hat SCL Apache, Python and PHP is discussed in the apache-php folder. As another example, to update the library documentation, perform a `make docs` on the local machine and then scp `CryptoPPRef.zip` to the webserver. On the webserver run `update-docs.sh` to unpack the ZIP where it belongs.
