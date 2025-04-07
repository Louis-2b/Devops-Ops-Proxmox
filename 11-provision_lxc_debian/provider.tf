terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.73.1" # Utilisez la dernière version stable
    }
    #random = {
      #source = "hashicorp/random"
      #version = "3.7.1"
    #}
  }
}

provider "proxmox" {
  endpoint  = var.endpoint  # URL de l'API Proxmox
  api_token = var.api_token # Token API
  insecure  = true          # Désactive la vérification TLS (utilisez `false` en production)
  ssh {
    agent       = false                          # Désactive l'agent SSH pour l'authentification
    username = var.ci_user                      # Nom d'utilisateur pour l'authentification
    private_key = file(var.ssh_private_key_path) # Chemin vers la clé privée
    
    #private_key = tls_private_key.ubuntu_container_key.private_key_pem  # Utilisation de la clé privée
  }
}