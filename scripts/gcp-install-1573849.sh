#!/bin/bash

# *** VM PRINCIPALE ***
# Créer la VM principale
gcloud compute instances create vm-main-1573849 \
--zone=northamerica-northeast1-a \
--machine-type=e2-medium \
--boot-disk-size=30GB \
--image-family=ubuntu-2404-lts-amd64 \
--image-project=ubuntu-os-cloud \
--provisioning-model=SPOT \
--instance-termination-action=STOP

gcloud compute instances add-tags vm-main-1573849 --zone=northamerica-northeast1-a \
--tags=web-server

# Vérifier l'installation de la VM
gcloud compute instances list

# Démarrer la VM principale
glcoud compute instances start vm-main-1573849 --zone=northamerica-northeast1-a


# *** FIREWALL GCLOUD ***
# Ouvrir le port 22 dans Google Cloud
gcloud compute firewall-rules create allow-ssh \
--network=default \
--direction=INGRESS \
--action=ALLOW \
--rules=tcp:22

# Vérifier l'ajout de la règle ssh
gcloud compute firewall-rules describe allow-ssh

# Ouvrir le port 80 seulement pour la VM principale
gcloud compute firewall-rules create allow-http \
--network=default \
--direction=INGRESS \
--action=ALLOW \
--rules=tcp:80 \
--target-tags=web-server

# Vérifier l'ajout de la règle http
gcloud compute firewall-rules describe allow-http

# Ouvrir le port 8080 seulement pour la VM principale
gcloud compute firewall-rules create allow-http-wordpress \
--network=default \
--direction=INGRESS \
--action=ALLOW \
--rules=tcp:8080 \
--target-tags=web-server

# Vérifier l'ajout de la règle http-wordpress
gcloud compute firewall-rules describe allow-http-wordpress


# *** BASE DE DONNÉES ***
# Créer la base de données
gcloud sql instances create db-wordpress-1573849 \
--region=northamerica-northeast1 \
--database-version=MYSQL_9_7 \
--edition=enterprise \
--tier=db-f1-micro \
--storage-size=10GB \
--storage-type=HDD \
--root-password=Travail123456789!

# Vérifier la création de la base de données
gcloud sql instances list

# Attribuer une adresse IP privée à la base de données et supprimer son adresse publique
gcloud sql instances patch db-wordpress-1573849 \
--network=projects/a26-3c3-19/global/networks/default \
--no-assign-ip

# Valider la modification
gcloud sql instances list

# Se connecter à la base de données via un proxy
curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.26.3/cloud-sql-proxy.linux.amd64
chmod +x cloud-sql-proxy
sudo install cloud-sql-proxy /usr/local/bin/cloud-sql-proxy

gcloud auth application-default login
cloud-sql-proxy --port 3306 a26-3c3-19:northamerica-northeast1:db-wordpress-1573849

# Dans un autre terminal
gcloud sql connect db-wordpress-1573849 --user=root



# *** VM SECONDAIRE ***
# Créer la VM secondaire
# TODO
