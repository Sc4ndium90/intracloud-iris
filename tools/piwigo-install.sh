#!/bin/bash
VERSION="15.7.0"
INSTALL_PATH="/var/www/piwigo/public_html"
ARCHIVE_NAME="piwigo-$VERSION.zip"
DOWNLOAD_PATH="/tmp/$ARCHIVE_NAME"
DOMAIN="piwigo.intracloud.local"
VH_FOLDER="/etc/apache2/sites-available/"
VH_CONFIG_NAME="piwigo.conf"

echo "[+] Downloading Piwigo tarball.."
wget --content-disposition -P /tmp "https://piwigo.org/download/dlcounter.php?code=$VERSION"

echo "[?] Checking if ${INSTALL_PATH} already exists"
if [ -d "$INSTALL_PATH" ]; then
	echo "[!] Folder ${INSTALL_PATH} already exists, skipping.."
	rm $DOWNLOAD_PATH
else
	echo "[+] Extracting files to ${INSTALL_PATH}"
	mkdir -p "${INSTALL_PATH}"
	unzip "${DOWNLOAD_PATH}" -d "${INSTALL_PATH}"
	mv "${INSTALL_PATH}/piwigo/"* "${INSTALL_PATH}/." && rmdir "${INSTALL_PATH}/piwigo"
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

    ErrorLog ${APACHE_LOG_DIR}/piwigo_error.log
    CustomLog ${APACHE_LOG_DIR}/piwigo_access.log combined

    <Directory ${INSTALL_PATH}>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" > "$VH_FOLDER/$VH_CONFIG_NAME"
	a2ensite $VH_CONFIG_NAME
	systemctl reload apache2
	echo "[/] Installation done - Finish installation on http://${DOMAIN}/"
fi

mysql -u root -e "CREATE DATABASE piwigo_db; CREATE USER 'piwigo_user'@'localhost' IDENTIFIED BY 'piwigo_password'; GRANT ALL PRIVILEGES ON piwigo_db.* TO 'piwigo_user'@'localhost'; FLUSH PRIVILEGES;"
