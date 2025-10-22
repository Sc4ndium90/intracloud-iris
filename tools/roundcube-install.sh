```bash
#!/bin/bash
VERSION="1.6.11"
INSTALL_PATH="/var/www/roundcube/public_html"
ARCHIVE_NAME="roundcubemail-$VERSION-complete.tar.gz"
DOWNLOAD_PATH="/tmp/$ARCHIVE_NAME"
DOMAIN="roundcube.intracloud.local"
VH_FOLDER="/etc/apache2/sites-available/"
VH_CONFIG_NAME="roundcube.conf"

echo "[+] Downloading RoundCube tarball.."
wget -P /tmp "https://github.com/roundcube/roundcubemail/releases/download/$VERSION/roundcubemail-$VERSION-complete.tar.gz"

echo "[?] Checking if ${INSTALL_PATH} already exists"
if [ -d "$INSTALL_PATH" ]; then
	echo "[!] Folder ${INSTALL_PATH} already exists, skipping.."
	rm $DOWNLOAD_PATH
else
	echo "[+] Extracting files to $INSTALL_PATH"
	mkdir -p "$INSTALL_PATH/public_html"
	tar zxf "${DOWNLOAD_PATH}" -C "${INSTALL_PATH}" --strip-components=1
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

    ErrorLog ${APACHE_LOG_DIR}/roundcube_error.log
    CustomLog ${APACHE_LOG_DIR}/roundcube_access.log combined

    <Directory ${INSTALL_PATH}>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" > "$VH_FOLDER/$VH_CONFIG_NAME"
	a2ensite $VH_CONFIG_NAME
	systemctl reload apache2
	echo "[/] Installation done - Finish installation on http://${DOMAIN}/"
fi

mysql -u root -e "CREATE DATABASE roundcube_db; CREATE USER 'roundcube_user'@'localhost' IDENTIFIED BY 'roundcube_password'; GRANT ALL PRIVILEGES ON roundcube_db.* TO 'roundcube_user'@'localhost'; FLUSH PRIVILEGES;"
