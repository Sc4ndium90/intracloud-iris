#!/bin/bash
if [ "$(id -u)" -ne 0 ]; then 
	exit 1 
fi

apt install -y lsb-release ca-certificates apt-transport-https wget
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/sury-php.list
apt update -y && apt upgrade -y 
apt install -y apache2 sudo mariadb-server mariadb-client mariadb-common php php8.4-common libapache2-mod-php php-mysql php-cli php-curl php-gd php8.4-xml php-mbstring php-zip php-intl php8.4-imap php-ldap php-imagick php-sqlite3 php-json php-tokenizer unzip libxml2
systemctl restart apache2 
apt autoremove -y

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
php -r "unlink('composer-setup.php');"

a2enmod rewrite
systemctl restart apache2

exit 0
