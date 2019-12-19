#!/usr/bin/env bash

wiki_root=/var/www/html/w
wiki_user=$(grep 'wgDBuser' "$wiki_root/LocalSettings.php" | cut -d '"' -f 2)
wiki_pass=$(grep 'wgDBpassword' "$wiki_root/LocalSettings.php" | cut -d '"' -f 2)

script_args=(
    "--dbuser=$wiki_user"
    "--dbpass=$wiki_pass"    
)

# "--config=$wiki_root/LocalSettings.php"

php "$wiki_root/maintenance/cleanupUsersWithNoId.php" "${script_args[@]}" --prefix="wikicryptopp_" --force
php "$wiki_root/maintenance/cleanupUsersWithNoId.php" "${script_args[@]}" --prefix="wikilounge_" --force

php "$wiki_root/maintenance/deleteArchivedFiles.php" "${script_args[@]}" --delete

php "$wiki_root/maintenance/deleteArchivedRevisions.php" "${script_args[@]}" --delete

php "$wiki_root/maintenance/deleteAutoPatrolLogs.php" "${script_args[@]}"

php "$wiki_root/maintenance/deleteDefaultMessages.php" "${script_args[@]}"

php "$wiki_root/maintenance/deleteEqualMessages.php" "${script_args[@]}"

php "$wiki_root/maintenance/deleteOldRevisions.php" "${script_args[@]}"

php "$wiki_root/maintenance/deleteOrphanedRevisions.php" "${script_args[@]}"

php "$wiki_root/maintenance/deleteSelfExternals.php" "${script_args[@]}"
