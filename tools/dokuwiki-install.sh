#!/bin/bash
VERSION="2025-05-14b"
INSTALL_PATH="/var/www/dokuwiki/public_html"
ARCHIVE_NAME="dokuwiki-$VERSION.tgz"
DOWNLOAD_PATH="/tmp/$ARCHIVE_NAME"
DOMAIN="dokuwiki.intracloud.local"
VH_FOLDER="/etc/apache2/sites-available/"
VH_CONFIG_NAME="dokuwiki.conf"
APACHE_LOG_DIR="/var/log/apache2"

echo "[+] Downloading DokuWiki tarball.."
wget -P /tmp "https://github.com/dokuwiki/dokuwiki/releases/download/release-$VERSION/dokuwiki-$VERSION.tgz"

echo "[?] Checking if ${INSTALL_PATH} already exists"
if [ -d "$INSTALL_PATH" ]; then
	echo "[!] Folder ${INSTALL_PATH} already exists, skipping.."
	rm $DOWNLOAD_PATH
else
	echo "[+] Extracting files to ${INSTALL_PATH}"
	mkdir -p $INSTALL_PATH/public_path
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

    ErrorLog ${APACHE_LOG_DIR}/dokuwiki_error.log
    CustomLog ${APACHE_LOG_DIR}/dokuwiki_access.log combined

    <Directory ${INSTALL_PATH}>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" > "$VH_FOLDER/$VH_CONFIG_NAME"
	a2ensite $VH_CONFIG_NAME
	systemctl reload apache2
	echo "[/] Installation done - Finish installation on http://${DOMAIN}/install.php"
fi
