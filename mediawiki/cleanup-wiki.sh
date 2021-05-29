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

# Pretty print
red_color='\033[0;31m'
cyan_color='\033[0;36m'
green_color='\033[0;32m'
no_color='\033[0m'

# Database cleanup

echo -e "${green_color}Running deleteArchivedFiles.php${no_color}"
php "$wiki_root/maintenance/deleteArchivedFiles.php" "${script_args[@]}" --delete --force

echo -e "${green_color}Running deleteArchivedRevisions.php${no_color}"
php "$wiki_root/maintenance/deleteArchivedRevisions.php" "${script_args[@]}" --delete

echo -e "${green_color}Running deleteAutoPatrolLogs.php${no_color}"
php "$wiki_root/maintenance/deleteAutoPatrolLogs.php" "${script_args[@]}"

echo -e "${green_color}Running deleteDefaultMessages.php${no_color}"
php "$wiki_root/maintenance/deleteDefaultMessages.php" "${script_args[@]}"

echo -e "${green_color}Running deleteEqualMessages.php${no_color}"
php "$wiki_root/maintenance/deleteEqualMessages.php" "${script_args[@]}"

echo -e "${green_color}Running deleteOldRevisions.php${no_color}"
php "$wiki_root/maintenance/deleteOldRevisions.php" "${script_args[@]}" --delete

echo -e "${green_color}Running deleteOrphanedRevisions.php${no_color}"
php "$wiki_root/maintenance/deleteOrphanedRevisions.php" "${script_args[@]}"

echo -e "${green_color}Running cleanupUsersWithNoId.php${no_color}"
php "$wiki_root/maintenance/cleanupUsersWithNoId.php" "${script_args[@]}" --prefix="*" --force

echo -e "${green_color}Running cleanupAncientTables.php${no_color}"
php "$wiki_root/maintenance/cleanupAncientTables.php" "${script_args[@]}" --force

echo -e "${green_color}Running cleanupBlocks.php${no_color}"
php "$wiki_root/maintenance/cleanupBlocks.php" "${script_args[@]}"

echo -e "${green_color}Running cleanupCaps.php${no_color}"
php "$wiki_root/maintenance/cleanupCaps.php" "${script_args[@]}"

echo -e "${green_color}Running cleanupEmptyCategories.php${no_color}"
php "$wiki_root/maintenance/cleanupEmptyCategories.php" "${script_args[@]}"

echo -e "${green_color}Running cleanupImages.php${no_color}"
php "$wiki_root/maintenance/cleanupImages.php" "${script_args[@]}"

echo -e "${green_color}Running cleanupInvalidDbKeys.php${no_color}"
php "$wiki_root/maintenance/cleanupInvalidDbKeys.php" "${script_args[@]}"

echo -e "${green_color}Running cleanupRemovedModules.php${no_color}"
php "$wiki_root/maintenance/cleanupRemovedModules.php" "${script_args[@]}"

echo -e "${green_color}Running cleanupRevActorPage.php${no_color}"
php "$wiki_root/maintenance/cleanupRevActorPage.php" "${script_args[@]}" --force

echo -e "${green_color}Running cleanupTitles.php${no_color}"
php "$wiki_root/maintenance/cleanupTitles.php" "${script_args[@]}"

echo -e "${green_color}Running cleanupUploadStash.php${no_color}"
php "$wiki_root/maintenance/cleanupUploadStash.php" "${script_args[@]}"

echo -e "${green_color}Running cleanupWatchlist.php${no_color}"
php "$wiki_root/maintenance/cleanupWatchlist.php" "${script_args[@]}" --fix

echo -e "${green_color}Running cleanupPreferences.php${no_color}"
php "$wiki_root/maintenance/cleanupPreferences.php" "${script_args[@]}" --hidden

echo -e "${green_color}Running cleanupPreferences.php${no_color}"
php "$wiki_root/maintenance/cleanupPreferences.php" "${script_args[@]}" --unknown

echo -e "${green_color}Running removeUnusedAccounts.php${no_color}"
php "$wiki_root/maintenance/removeUnusedAccounts.php" "${script_args[@]}" --delete

# Database maintenance

echo -e "${green_color}Running rebuildImages.php${no_color}"
php "$wiki_root/maintenance/rebuildImages.php" "${script_args[@]}"

echo -e "${green_color}Running rebuildmessages.php${no_color}"
php "$wiki_root/maintenance/rebuildmessages.php"

echo -e "${green_color}Running rebuildtextindex.php${no_color}"
php "$wiki_root/maintenance/rebuildtextindex.php" "${script_args[@]}"

echo -e "${green_color}Running rebuildFileCache.php${no_color}"
php "$wiki_root/maintenance/rebuildFileCache.php" "${script_args[@]}"

echo -e "${green_color}Running refreshLinks.php${no_color}"
php "$wiki_root/maintenance/refreshLinks.php" "${script_args[@]}"

echo -e "${green_color}Running rebuildLocalisationCache.php${no_color}"
# php "$wiki_root/maintenance/rebuildLocalisationCache.php" --force
echo -e "${red_color}Skipping... See https://phabricator.wikimedia.org/T251850${no_color}"

#Removed at Mediawiki 1.36
#echo -e "${green_color}Running rebuildAll.php${no_color}"
#php "$wiki_root/maintenance/rebuildall.php"
