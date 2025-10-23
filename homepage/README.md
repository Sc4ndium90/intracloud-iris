# Homepage for the project
The homepage is needed for the project to allow user to access quickly each "apps".

To "install" this page :
- Create the folder /var/www/public_html
- Upload the file "index.html" in it
- Upload the VirtualHost file (rename it "accueil.conf")
- Change the owner and rights of the folder (www-data:www-data - 755)
- Enable the VirtualHost and reload Apache2

Don't forget the DNS entry to access this page (accueil.intracloud.local)
