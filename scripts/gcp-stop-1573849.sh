#!/bin/bash

# Arrêter les VMs
gcloud compute instances stop vm-main-1573849 --zone=northamerica-northeast1-a

# Arrêter la base de données
gcloud sql instances patch db-wordpress-1573849 --activation-policy=NEVER