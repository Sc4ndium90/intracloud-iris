In order to make Kimai work, there are post-installation commands to run : edit the .env file and "install" Kimai:

Edit the .env file in /var/www/kimai/public_html
```
cd /var/www/kimai/public_html
nano .env

#Edit the DATABASE_URL
DATABASE_URL=mysql://kimai_user:kimai_password@127.0.0.1:3306/kimai_db?charset=utf8mb4&serverVersion=11.8.3-MariaDB
```

Then "install" Kimai and create an admin user:
```
bin/console kimai:install -n
bin/console kimai:user:create admin admin@example.com ROLE_SUPER_ADMIN
```
