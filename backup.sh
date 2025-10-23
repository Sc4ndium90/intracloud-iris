#!/bin/bash
ROOT_BACKUP_FOLDER=/mnt/windows-backup
ANNEE_MOIS=$(date +\%Y-\%m)
JOUR=$(date +\%d)
#Example : /mnt/windows-backup/2025-10/23
DEST_BACKUP_FOLDER="$ROOT_BACKUP_FOLDER/$ANNEE_MOIS/$JOUR"
TEMP_DB_BACKUP_FOLDER="/tmp/db"
DATABASES=("kimai_db" "limesurvey_db" "mybb_db" "nextcloud_db" "osticket_db" "piwigo_db" "roundcube_db")

if [ ! -d "$TEMP_DB_BACKUP_FOLDER" ]; then
	mkdir -p $TEMP_DB_BACKUP_FOLDER
fi

#Create directory if it doesnt exists
echo "[?] Check if backup folder already exist"
if [ ! -d "$DEST_BACKUP_FOLDER" ]; then
	echo "[+] Creating backup folder $DEST_BACKUP_FOLDER"
	mkdir -p $DEST_BACKUP_FOLDER
else
	echo "[!] Folder already exists! Skipping.."
fi

echo "[+] Backing up SQL Databases"
for DB_NAME in ${DATABASES[@]}; do
	OUTPUT_FILE="$DB_NAME.sql"
	mysqldump -u root "$DB_NAME" > "$TEMP_DB_BACKUP_FOLDER/$OUTPUT_FILE"
done
cd $TEMP_DB_BACKUP_FOLDER && tar -cvzf "$DEST_BACKUP_FOLDER/database.tar.gz" *
cd /var/www && rm -rf $TEMP_DB_BACKUP_FOLDER
echo "[✓] SQL Databases backup done!"

echo "[+] Backing up websites"
tar -cvzf "$DEST_BACKUP_FOLDER/websites.tar.gz" *
echo "[✓] Websites backup done!"
