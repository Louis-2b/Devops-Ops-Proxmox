terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.73.1" # Utilisez la dernière version stable
    }
  }
}

provider "proxmox" {
  endpoint  = var.endpoint  # URL de l'API Proxmox
  api_token = var.api_token # Token API
  insecure  = true          # Désactive la vérification TLS (utilisez `false` en production)
  ssh {
    agent       = false                          # Désactive l'agent SSH pour l'authentification
    username    = var.username                    # Utilisateur SSH
  }
}