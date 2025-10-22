#!/bin/bash
VERSION="v1.18.2"
INSTALL_PATH="/var/www/osticket/public_html"
ARCHIVE_NAME="osTicket-$VERSION.zip"
DOWNLOAD_PATH="/tmp/$ARCHIVE_NAME"
DOMAIN="support.intracloud.local"
VH_FOLDER="/etc/apache2/sites-available/"
VH_CONFIG_NAME="osticket.conf"

echo "[+] Downloading OsTicket zip.."
wget -P /tmp "https://github.com/osTicket/osTicket/releases/download/${VERSION}/osTicket-${VERSION}.zip"

echo "[?] Checking if ${INSTALL_PATH} already exists"
if [ -d "$INSTALL_PATH" ]; then
	echo "[!] Folder ${INSTALL_PATH} already exists, skipping.."
	rm $DOWNLOAD_PATH
else
	echo "[+] Extracting files to ${INSTALL_PATH}"
	mkdir -p "${INSTALL_PATH}"
	unzip "${DOWNLOAD_PATH}" -d "${INSTALL_PATH}"
	mv "${INSTALL_PATH}/upload/"* "${INSTALL_PATH}/." && rmdir "${INSTALL_PATH}/upload" && rm -rf "${INSTALL_PATH}/scripts"
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

    ErrorLog ${APACHE_LOG_DIR}/osticket_error.log
    CustomLog ${APACHE_LOG_DIR}/osticket_access.log combined

    <Directory ${INSTALL_PATH}>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" > "$VH_FOLDER/$VH_CONFIG_NAME"
	a2ensite $VH_CONFIG_NAME
	systemctl reload apache2
	echo "[/] Installation done - Finish installation on http://${DOMAIN}/"
fi

mysql -u root -e "CREATE DATABASE osticket_db; CREATE USER 'osticket_user'@'localhost' IDENTIFIED BY 'osticket_password'; GRANT ALL PRIVILEGES ON osticket_db.* TO 'osticket_user'@'localhost'; FLUSH PRIVILEGES;"
