#!/bin/bash
VERSION="32.0.0"
INSTALL_PATH="/var/www/nextcloud/public_html"
ARCHIVE_NAME="nextcloud-$VERSION.tar.bz2"
DOWNLOAD_PATH="/tmp/$ARCHIVE_NAME"
DOMAIN="files.intracloud.local"
VH_FOLDER="/etc/apache2/sites-available/"
VH_CONFIG_NAME="nextcloud.conf"

echo "[+] Downloading Nextcloud tarball.."
wget -P /tmp "https://github.com/nextcloud-releases/server/releases/download/v$VERSION/nextcloud-$VERSION.tar.bz2"

echo "[?] Checking if ${INSTALL_PATH} already exists"
if [ -d "$INSTALL_PATH" ]; then
	echo "[!] Folder ${INSTALL_PATH} already exists, skipping.."
	rm $DOWNLOAD_PATH
else
	echo "[+] Extracting files to $INSTALL_PATH"
	mkdir -p "$INSTALL_PATH/public_html"
	tar xvjf "${DOWNLOAD_PATH}" -C "${INSTALL_PATH}" --strip-components=1
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

    ErrorLog ${APACHE_LOG_DIR}/nextcloud_error.log
    CustomLog ${APACHE_LOG_DIR}/nextcloud_access.log combined

    <Directory ${INSTALL_PATH}>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" > "$VH_FOLDER/$VH_CONFIG_NAME"
	a2ensite $VH_CONFIG_NAME
	systemctl reload apache2
	echo "[/] Installation done - Finish installation on http://${DOMAIN}/install.php"
fi

mysql -u root -e "CREATE DATABASE nextcloud_db; CREATE USER 'nextcloud_user'@'localhost' IDENTIFIED BY 'nextcloud_password'; GRANT ALL PRIVILEGES ON nextcloud_db.* TO 'nextcloud_user'@'localhost'; FLUSH PRIVILEGES;"
