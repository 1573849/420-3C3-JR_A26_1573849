#!/bin/bash

# Se connecter à la VM
gcloud compute ssh vm-main-1573849 --zone=northamerica-northeast1-a

# Installer les services
sudo apt update
sudo apt install nginx
sudo apt install php-fpm
sudo apt install php-mysql

# Démarrer les services
sudo systemctl start nginx
sudo systemctl enable nginx

# Vérifier les installations
sudo systemctl status nginx
sudo systemctl status php*

# *** Dans WLS ***
# Transférer les fichiers de Windows vers la machine Linux
code .

# Transférer les fichiers du site par défaut vers la VM
gcloud compute scp ~/site-web-default.zip vm-main-1573849:/tmp/

# *** Dans la VM ***
# Écraser les fichiers du site par défaut
cd /var/www/html
sudo apt install unzip
sudo unzip /tmp/site-web-default.zip
sudo rm /tmp/site-web-default.zip

# Obtenir les fichiers Wordpress
cd /tmp 
wget https://wordpress.org/latest.tar.gz
tar -xvf latest.tar.gz
ls -la /tmp/wordpress

sudo mv /tmp/wordpress/ /var/www/wordpress/
ls -la /var/www/
ls -la /var/www/wordpress

# Attribuer les droits à nginx
sudo chown -R www-data:www-data /var/www/wordpress
sudo chmod -R u=rwX,go=rX /var/www/wordpress

# Créer le site Wordpress dans nginx
cd /etc/nginx/sites-available
sudo cp default wordpress
sudo nano wordpress

# Activer le site Wordpress
cd ../sites-enabled
sudo ln -s /etc/nginx/sites-available/wordpress wordpress