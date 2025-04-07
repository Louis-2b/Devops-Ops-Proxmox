terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.73.1" # Utilisez la dernière version stable
    }
    #random = {
    #source  = "hashicorp/random"
    #version = "3.7.1"
    #}
  }
}

provider "proxmox" {
  endpoint = var.endpoint # URL de l'API Proxmox
  username = var.username # Nom d'utilisateur
  password = var.password # Mot de passe
  insecure = true         # Désactive la vérification TLS (utilisez `false` en production)
}