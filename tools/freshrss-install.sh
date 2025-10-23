#!/bin/bash
VERSION="1.27.0"
INSTALL_PATH="/var/www/freshrss/public_html"
ARCHIVE_NAME="$VERSION.tar.gz"
DOWNLOAD_PATH="/tmp/$ARCHIVE_NAME"
DOMAIN="freshrss.intracloud.local"
VH_FOLDER="/etc/apache2/sites-available/"
VH_CONFIG_NAME="freshrss.conf"
APACHE_LOG_DIR="/var/log/apache2"

echo "[+] Downloading FreshRSS tarball.."
wget -P /tmp "https://github.com/FreshRSS/FreshRSS/archive/refs/tags/$VERSION.tar.gz"

echo "[?] Checking if ${INSTALL_PATH} already exists"
if [ -d "$INSTALL_PATH" ]; then
	echo "[!] Folder ${INSTALL_PATH} already exists, skipping.."
	rm $DOWNLOAD_PATH
else
	echo "[+] Extracting files to ${INSTALL_PATH}"
	mkdir -p "${INSTALL_PATH}"
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

    ErrorLog ${APACHE_LOG_DIR}/freshrss_error.log
    CustomLog ${APACHE_LOG_DIR}/freshrss_access.log combined

    <Directory ${INSTALL_PATH}>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" > "$VH_FOLDER/$VH_CONFIG_NAME"
	a2ensite $VH_CONFIG_NAME
	systemctl reload apache2
	echo "[/] Installation done - Finish installation on http://${DOMAIN}/"
fi
