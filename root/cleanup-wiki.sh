#!/usr/bin/env bash

# Be careful with cleanupSpam.php. The domain argument is
# the spam domain, and not localhost or cryptopp.com.

wiki_root=/var/www/html/w
wiki_user=$(grep 'wgDBuser' "$wiki_root/LocalSettings.php" | cut -d '"' -f 2)
wiki_pass=$(grep 'wgDBpassword' "$wiki_root/LocalSettings.php" | cut -d '"' -f 2)

# https://phabricator.wikimedia.org/T172060
# "--config=$wiki_root/LocalSettings.php"
script_args=(
    "--dbuser=$wiki_user"
    "--dbpass=$wiki_pass"
    "--server=https://www.cryptopp.com/wiki/"
)

php "$wiki_root/maintenance/deleteArchivedFiles.php" "${script_args[@]}" --delete --force

php "$wiki_root/maintenance/deleteArchivedRevisions.php" "${script_args[@]}" --delete

php "$wiki_root/maintenance/deleteAutoPatrolLogs.php" "${script_args[@]}"

php "$wiki_root/maintenance/deleteDefaultMessages.php" "${script_args[@]}"

php "$wiki_root/maintenance/deleteEqualMessages.php" "${script_args[@]}"

php "$wiki_root/maintenance/deleteOldRevisions.php" "${script_args[@]}"

php "$wiki_root/maintenance/deleteOrphanedRevisions.php" "${script_args[@]}"

php "$wiki_root/maintenance/deleteSelfExternals.php" "${script_args[@]}"

php "$wiki_root/maintenance/cleanupUsersWithNoId.php" "${script_args[@]}" --prefix="wikicryptopp_" --force
php "$wiki_root/maintenance/cleanupUsersWithNoId.php" "${script_args[@]}" --prefix="wikilounge_" --force

php "$wiki_root/maintenance/cleanupAncientTables.php" "${script_args[@]}" --force

php "$wiki_root/maintenance/cleanupBlocks.php" "${script_args[@]}"

php "$wiki_root/maintenance/cleanupCaps.php" "${script_args[@]}"

php "$wiki_root/maintenance/cleanupEmptyCategories.php" "${script_args[@]}"

php "$wiki_root/maintenance/cleanupImages.php" "${script_args[@]}"

php "$wiki_root/maintenance/cleanupInvalidDbKeys.php" "${script_args[@]}"

php "$wiki_root/maintenance/cleanupRemovedModules.php" "${script_args[@]}"

php "$wiki_root/maintenance/cleanupRevActorPage.php" "${script_args[@]}" --force

php "$wiki_root/maintenance/cleanupTitles.php" "${script_args[@]}"

php "$wiki_root/maintenance/cleanupUploadStash.php" "${script_args[@]}"

php "$wiki_root/maintenance/cleanupWatchlist.php" "${script_args[@]}" --fix

php "$wiki_root/maintenance/cleanupPreferences.php" "${script_args[@]}" --hidden

php "$wiki_root/maintenance/cleanupPreferences.php" "${script_args[@]}" --unknown
