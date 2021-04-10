#!/usr/bin/env bash

# This script tidies up the wiki installation.

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

# Database cleanup

php "$wiki_root/maintenance/deleteArchivedFiles.php" "${script_args[@]}" --delete --force

php "$wiki_root/maintenance/deleteArchivedRevisions.php" "${script_args[@]}" --delete

php "$wiki_root/maintenance/deleteAutoPatrolLogs.php" "${script_args[@]}"

php "$wiki_root/maintenance/deleteDefaultMessages.php" "${script_args[@]}"

php "$wiki_root/maintenance/deleteEqualMessages.php" "${script_args[@]}"

php "$wiki_root/maintenance/deleteOldRevisions.php" "${script_args[@]}" --delete

php "$wiki_root/maintenance/deleteOrphanedRevisions.php" "${script_args[@]}"

php "$wiki_root/maintenance/cleanupUsersWithNoId.php" "${script_args[@]}" --prefix="*" --force

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

php "$wiki_root/maintenance/removeUnusedAccounts.php" "${script_args[@]}" --delete

# Database maintenance

php "$wiki_root/maintenance/rebuildImages.php" "${script_args[@]}"

php "$wiki_root/maintenance/rebuildtextindex.php" "${script_args[@]}"

php "$wiki_root/maintenance/refreshLinks.php" "${script_args[@]}"