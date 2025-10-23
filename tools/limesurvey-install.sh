#!/bin/bash
INSTALL_PATH="/var/www/limesurvey/public_html"
ARCHIVE_NAME="limesurvey6.15.20+251021.zip"
DOWNLOAD_PATH="/tmp/$ARCHIVE_NAME"
DOMAIN="survey.intracloud.local"
VH_FOLDER="/etc/apache2/sites-available/"
VH_CONFIG_NAME="limesurvey.conf"
APACHE_LOG_DIR="/var/log/apache2"

echo "[+] Downloading LimeSurvey zip.."
wget -P /tmp "https://download.limesurvey.org/latest-master/limesurvey6.15.20+251021.zip"

echo "[?] Checking if ${INSTALL_PATH} already exists"
if [ -d "$INSTALL_PATH" ]; then
	echo "[!] Folder ${INSTALL_PATH} already exists, skipping.."
	rm $DOWNLOAD_PATH
else
	echo "[+] Extracting files to ${INSTALL_PATH}"
	mkdir -p "${INSTALL_PATH}"
	unzip "${DOWNLOAD_PATH}" -d "${INSTALL_PATH}"
	mv "${INSTALL_PATH}/limesurvey/"* "${INSTALL_PATH}/." && rmdir "${INSTALL_PATH}/limesurvey"
	chown -R www-data:www-data "${INSTALL_PATH}"
	chmod -R 755 "${INSTALL_PATH}"
	rm $DOWNLOAD_PATH
fi

echo "[?] Checking if VirtualHost already exists"
if [ -f "$VH_FOLDER/$VH_CONFIG_NAME" ]; then
	echo "[!] Virtual Host already exists, skipping.."
else
	echo "<VirtualHost *:80>
    ServerName ${DOMAIN}
    DocumentRoot ${INSTALL_PATH}

    ErrorLog ${APACHE_LOG_DIR}/limesurvey_error.log
    CustomLog ${APACHE_LOG_DIR}/limesurvey_access.log combined

    <Directory ${INSTALL_PATH}>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" > "$VH_FOLDER/$VH_CONFIG_NAME"
	a2ensite $VH_CONFIG_NAME
	systemctl reload apache2
	echo "[/] Installation done - Finish installation on http://${DOMAIN}/"
fi

mysql -u root -e "CREATE DATABASE limesurvey_db; CREATE USER 'limesurvey_user'@'localhost' IDENTIFIED BY 'limesurvey_password'; GRANT ALL PRIVILEGES ON limesurvey_db.* TO 'limesurvey_user'@'localhost'; FLUSH PRIVILEGES;"
