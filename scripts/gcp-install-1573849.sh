#!/bin/bash

# GOOGLE CLOUD
# -------------------------------------------------------------------------------
# Installer la machien Linux locales
wsl --install

sudo apt-get update
sudo apt-get install ca-certificates gnupg curl

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# Se connecter au projet
gcloud init
gcloud projects list		
gcloud config set project a26-3c3-19
gcloud auth application-default login 1573849@cstj.qc.ca --no-launch-browser

# Allouer un bloc d'adresses interne pour le réseau privé du projet et l'utiliser par défaut
gcloud services enable servicenetworking.googleapis.com
gcloud compute addresses create adresses-reseau-interne \
  --global \
  --purpose=VPC_PEERING \
  --prefix-length=16 \
  --network=default
gcloud services vpc-peerings connect \
  --service=servicenetworking.googleapis.com \
  --ranges=adresses-reseau-interne \
  --network=default


# VM PRINCIPALE
# -------------------------------------------------------------------------------
# Créer la VM principale avec le tag 'web-server'
gcloud compute instances create vm-main-1573849 \
--zone=northamerica-northeast1-a \
--machine-type=e2-medium \
--boot-disk-size=30GB \
--image-family=ubuntu-2404-lts-amd64 \
--image-project=ubuntu-os-cloud \
--provisioning-model=SPOT \
--instance-termination-action=STOP \
--tags=web-server

# Vérifier l'installation de la VM
gcloud compute instances list

# Démarrer la VM
glcoud compute instances start vm-main-1573849 --zone=northamerica-northeast1-a


# FIREWALL GCLOUD
# -------------------------------------------------------------------------------
# Ouvrir le port 22 dans Google Cloud pour la connexion ssh
gcloud compute firewall-rules create allow-ssh \
--network=default \
--direction=INGRESS \
--action=ALLOW \
--rules=tcp:22

# Vérifier l'ajout de la règle ssh
gcloud compute firewall-rules describe allow-ssh

# Ouvrir le port 80 seulement pour la VM principale (web-server)
gcloud compute firewall-rules create allow-http \
--network=default \
--direction=INGRESS \
--action=ALLOW \
--rules=tcp:80 \
--target-tags=web-server

# Vérifier l'ajout de la règle http
gcloud compute firewall-rules describe allow-http

# Ouvrir le port 8080 seulement pour la VM principale (web-server)
gcloud compute firewall-rules create allow-http-wordpress \
--network=default \
--direction=INGRESS \
--action=ALLOW \
--rules=tcp:8080 \
--target-tags=web-server

# Vérifier l'ajout de la règle http-wordpress
gcloud compute firewall-rules describe allow-http-wordpress


# BASE DE DONNÉES
# -------------------------------------------------------------------------------
# Activer le service SQL dans le projet
gcloud services enable sqladmin.googleapis.com

# Créer la VM pour la base de données avec une adresse IP privé seulement
gcloud sql instances create db-wordpress-1573849 \
--region=northamerica-northeast1 \
--database-version=MYSQL_9_7 \
--edition=enterprise \
--tier=db-f1-micro \
--storage-size=10GB \
--storage-type=HDD \
--root-password='Travail123456789!' \
--network=projects/a26-3c3-19/global/networks/default \
--no-assign-ip

# Vérifier la création de la VM pour la base de données
gcloud sql instances list

# Créer la base de données pour wordpress
gcloud sql databases create wordpress --instance=db-wordpress-1573849

# *** Dans une VM du même réseau local que la DB ***
# Installer mysql-client pour la connexion à la DB
sudo apt update
sudo apt install mysql-client

# Installer un proxy pour la connexion à la DB
curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.26.3/cloud-sql-proxy.linux.amd64
chmod +x cloud-sql-proxy
sudo install cloud-sql-proxy /usr/local/bin/cloud-sql-proxy

# Démarrer le proxy
gcloud auth application-default login
cloud-sql-proxy --port 3306 a26-3c3-19:northamerica-northeast1:db-wordpress-1573849 --private-ip

# Se connecter à la base de données dans une autre instance du terminal de la VM
mysql -h 127.0.0.1 --port 3306 -u root -p --get-server-public-key

# Faire les modifications nécessaires à la base de données


# VM SECONDAIRE
# -------------------------------------------------------------------------------
# Créer la VM secondaire
# TODO
