#!/bin/bash
VERSION="1839"
INSTALL_PATH="/var/www/mybb/public_html"
ARCHIVE_NAME="mybb_$VERSION.zip"
DOWNLOAD_PATH="/tmp/$ARCHIVE_NAME"
DOMAIN="forum.intracloud.local"
VH_FOLDER="/etc/apache2/sites-available/"
VH_CONFIG_NAME="mybb.conf"
APACHE_LOG_DIR="/var/log/apache2"

echo "[+] Downloading MyBB zip.."
wget -P /tmp "https://github.com/mybb/mybb/releases/download/mybb_${VERSION}/mybb_${VERSION}.zip"

echo "[?] Checking if ${INSTALL_PATH} already exists"
if [ -d "$INSTALL_PATH" ]; then
	echo "[!] Folder ${INSTALL_PATH} already exists, skipping.."
	rm $DOWNLOAD_PATH
else
	echo "[+] Extracting files to ${INSTALL_PATH}"
	mkdir -p "${INSTALL_PATH}"
	unzip "${DOWNLOAD_PATH}" -d "${INSTALL_PATH}"
	mv "${INSTALL_PATH}/Upload/"* "${INSTALL_PATH}/." && rmdir "${INSTALL_PATH}/Upload" && rm -rf "${INSTALL_PATH}/Documentation"
	chown -R www-data:www-data "${INSTALL_PATH}"
	chmod -R 755 "${INSTALL_PATH}"
	rm $DOWNLOAD_PATH
	mv "${INSTALL_PATH}/htaccess.txt" "${INSTALL_PATH}/.htaccess"
fi

echo "[?] Checking if VirtualHost already exists"
if [ -f "$VH_FOLDER/$VH_CONFIG_NAME" ]; then
	echo "[!] Virtual Host already exists, skipping.."
else
	echo "<VirtualHost *:80>
    ServerName ${DOMAIN}
    DocumentRoot ${INSTALL_PATH}

    ErrorLog ${APACHE_LOG_DIR}/mybb_error.log
    CustomLog ${APACHE_LOG_DIR}/mybb_access.log combined

    <Directory ${INSTALL_PATH}>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" > "$VH_FOLDER/$VH_CONFIG_NAME"
	a2ensite $VH_CONFIG_NAME
	systemctl reload apache2
	echo "[/] Installation done - Finish installation on http://${DOMAIN}/"
fi

mysql -u root -e "CREATE DATABASE mybb_db; CREATE USER 'mybb_user'@'localhost' IDENTIFIED BY 'mybb_password'; GRANT ALL PRIVILEGES ON mybb_db.* TO 'mybb_user'@'localhost'; FLUSH PRIVILEGES;"
