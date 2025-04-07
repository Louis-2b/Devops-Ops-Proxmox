# 📌 Création de la VM Ansible
resource "proxmox_virtual_environment_vm" "k8s" {
  # -- Paramètres généraux
  count     = 2
  vm_id     = 356 + count.index             # ID unique pour chaque VM (352, 353)
  name      = "k8s${count.index + 1}"       # Nom de la VM
  node_name = "pve1"                        # Nom du nœud Proxmox
  tags      = ["terraform", "k8s", "clone"] # Tags pour organiser les VMs


  # -- Paramètres de démarrage
  on_boot = true # Démarre la VM automatiquement au démarrage de l'hôte

  # -- Agent QEMU
  agent {
    enabled = true # Active l'agent QEMU pour une meilleure gestion
    timeout = "2m" # Réduit à 2 minutes au lieu de 15m par défaut
  }

  # -- 🖥️ Paramètres Matériels
  cpu {
    cores = 2               # Nombre de cœurs CPU
    type  = "x86-64-v2-AES" # Type de CPU recommandé pour les processeurs modernes
  }

  memory {
    dedicated = 4096 # 🔥 Augmenté pour les playbooks Ansible
  }

  # -- 🌐 Paramètres Réseau 
  network_device {
    bridge   = "vmbr0"  # Pont réseau à utiliser
    model    = "virtio" # Modèle de carte réseau (virtio est recommandé)
    firewall = false    # Désactivation du pare-feu en production
    enabled  = true     # Active l'interface réseau
  }

  lifecycle {
    ignore_changes = [
      network_device, # Ne pas redémarrer la VM si la carte réseau change
    ]
  }

  # -- Ordre de démarrage et matériel SCSI
  boot_order    = ["scsi0"]
  scsi_hardware = "virtio-scsi-pci"

  # -- 💾 Paramètres Stockage principal
  disk {
    interface    = "scsi0"
    datastore_id = "local-backup" # Stockage local
    size         = 40             # 🔥 40 Go pour plus de flexibilité
    discard      = "on"           # Active TRIM/DISCARD
    file_format  = "raw"          # Optimisé pour les performances
    ssd          = true
  }

  # -- 📌 Clonage depuis un modèle existant
  clone {
    vm_id     = 350    # ID de la VM modèle à cloner
    node_name = "pve1" # Nœud où se trouve la VM modèle
    full      = true   # Crée un clone complet (false pour un clone lié)
    retries   = 3      # Nombre de tentatives en cas d'échec
  }

  # -- 📡Paramètres Cloud-Init
  initialization {
    ip_config {
      ipv4 {
        address = "192.168.222.9${count.index + 6}/24" # IPs : 192.168.222.96, 192.168.222.97
        gateway = "192.168.222.2"                      # Passerelle par défaut
      }
    }

    dns {
      servers = ["192.168.222.2", "8.8.8.8"] # DNS primaire + secours
    }

    user_account {
      username = var.username
      password = var.password
      keys     = [file(var.ssh_public_key_path)] # Clé publique pour SSH dans la VM
    }
  }
}

output "ssh_public_key_path" {
  value = var.ssh_public_key_path
}

output "vm_ips" {
  value       = [for vm in proxmox_virtual_environment_vm.k8s : vm.initialization[0].ip_config[0].ipv4[0].address]
  description = "Adresses IP des VMs crées"
}