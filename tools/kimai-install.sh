#!/bin/bash
VERSION="2.40.0"
INSTALL_PATH="/var/www/kimai/public_html"
ARCHIVE_NAME="$VERSION.tar.gz"
DOWNLOAD_PATH="/tmp/$ARCHIVE_NAME"
DOMAIN="kimai.intracloud.local"
VH_FOLDER="/etc/apache2/sites-available/"
VH_CONFIG_NAME="kimai.conf"
APACHE_LOG_DIR="/var/log/apache2"

#OK
echo "[+] Downloading Kimai tarball.."
wget -P /tmp "https://github.com/kimai/kimai/archive/refs/tags/$VERSION.tar.gz"

#OK
echo "[?] Checking if ${INSTALL_PATH} already exists"
if [ -d "$INSTALL_PATH" ]; then
	echo "[!] Folder ${INSTALL_PATH} already exists, skipping.."
	rm $DOWNLOAD_PATH
else
	echo "[+] Extracting files to $INSTALL_PATH"
	mkdir -p "$INSTALL_PATH"
	tar zxf "${DOWNLOAD_PATH}" -C "${INSTALL_PATH}" --strip-components=1
	chown -R www-data:www-data "${INSTALL_PATH}"
	chmod -R 755 "${INSTALL_PATH}"
	rm $DOWNLOAD_PATH
	
	cd ${INSTALL_PATH}
	sudo -u www-data composer install --no-dev --optimize-autoloader
fi

#OK
echo "[?] Checking if VirtualHost already exists"
if [ -f "$VH_FOLDER/$VH_CONFIG_NAME" ]; then
	echo "[!] Virtual Host already exists, skipping.."
else
	echo "<VirtualHost *:80>
    ServerName $DOMAIN

    DocumentRoot ${INSTALL_PATH}/public
    <Directory ${INSTALL_PATH}/public>
        AllowOverride All
		Require all granted

        FallbackResource /index.php
    </Directory>

    <Directory ${INSTALL_PATH}>
        Options FollowSymlinks
    </Directory>

    # optionally disable the fallback resource for the asset directories
    # which will allow Apache to return a 404 error when files are
    # not found instead of passing the request to Symfony
    <Directory ${INSTALL_PATH}/public/bundles>
        FallbackResource disabled
    </Directory>
    
    ErrorLog  ${APACHE_LOG_DIR}/kimai_error.log
    CustomLog ${APACHE_LOG_DIR}/kimai_access.log combined

</VirtualHost>" > "$VH_FOLDER/$VH_CONFIG_NAME"
	a2ensite $VH_CONFIG_NAME
	systemctl reload apache2
	echo "[/] Installation done - Finish installation on http://${DOMAIN}/"
fi

# OK
mysql -u root -e "CREATE DATABASE kimai_db; CREATE USER 'kimai_user'@'localhost' IDENTIFIED BY 'kimai_password'; GRANT ALL PRIVILEGES ON kimai_db.* TO 'kimai_user'@'localhost'; FLUSH PRIVILEGES;"
