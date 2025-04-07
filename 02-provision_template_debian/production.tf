# 📌 Création de la VM Ubuntu
resource "proxmox_virtual_environment_vm" "debian_template" {
  description = "Managed by Terraform"
  vm_id       = var.vm_id                             # ID de la VM, doit être unique dans le cluster Proxmox
  name        = "debian12-template"                   # Nom de la VM
  node_name   = var.node_name                         # Nom du nœud Proxmox sur lequel la VM sera créée
  tags        = ["terraform", "debian12", "template"] # Tags pour organiser les ressources

  # -- Paramètres de démarrage
  on_boot  = true # Démarre la VM automatiquement au démarrage de l'hôte
  template = true # À mettre à false seulement si vous ne créez pas un template
  started  = false

  # -- 🖥️ Paramètres Matériels
  cpu {
    cores = 2               # Nombre de cœurs CPU
    type  = "x86-64-v2-AES" # Type de CPU recommandé pour les processeurs modernes
  }

  # -- Agent QEMU
  agent {
    # lisez la section 'Agent invité Qemu', changez en true uniquement lorsque prêt
    enabled = true # Active l'agent QEMU pour une meilleure gestion de la VM
    timeout = "2m" # Réduit à 2 minutes au lieu de 15m par défaut
  }

  # Configuration du démarrage du conteneur
  startup {
    order      = "3"  # Ordre de démarrage
    up_delay   = "60" # Délai avant de démarrer (en secondes)
    down_delay = "60" # Délai avant d'arrêter (en secondes)
  }

  memory {
    dedicated = 1024 # Mémoire dédiée en Mo
    floating  = 1024 # Mémoire flottante (gonflement), définir égal à la mémoire dédiée pour activer le gonflement
  }

  # -- 💾 Paramètres Stockage principal
  disk {
    interface    = "scsi0"        # Interface de disque
    datastore_id = "local-backup" # ID du datastore où le disque sera stocké
    file_id      = proxmox_virtual_environment_download_file.latest_debian_12_bookworm_qcow2_img.id
    size         = 20   # 🔥 20 Go pour plus de flexibilité
    discard      = "on" # Active TRIM/DISCARD pour optimiser l'espace disque
    ssd          = true
  }

  # -- Initialisation de la VM
  initialization {
    ip_config {
      ipv4 {
        address = "192.168.222.80/24" # Adresse IP statique
        gateway = "192.168.222.2"     # Passerelle par défaut
      }
    }

    # Configuration DNS
    dns {
      servers = ["192.168.222.2", "8.8.8.8"] # DNS primaire + secours
    }

    # Compte utilisateur
    user_account {
      username = "steph"                         # Nom d'utilisateur
      keys     = [file(var.ssh_public_key_path)] # Clé publique pour SSH dans la VM

      #password = random_password.ubuntu_vm_password.result # Mot de passe aléatoire
      #keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
    }
  }

  # -- Configuration réseau
  network_device {
    bridge   = "vmbr0"  # Pont réseau
    model    = "virtio" # Modèle de carte réseau (virtio est recommandé)
    firewall = false    # Désactivation du pare-feu en production
    enabled  = true     # Active l'interface réseau
  }

  # -- Système d'exploitation
  operating_system {
    type = "l26" # Type de système d'exploitation (Linux 2.6+)
  }

  # -- Module TPM (Trusted Platform Module)
  tpm_state {
    version = "v2.0" # Version du TPM
  }

  # -- Périphérique série (optionnel)
  serial_device {
    device = "socket"
  }
}

resource "proxmox_virtual_environment_download_file" "latest_debian_12_bookworm_qcow2_img" {
  content_type = "iso"
  datastore_id = var.datastore_id
  file_name    = "debian-12-generic-amd64.qcow2.img"
  node_name    = var.node_name
  url          = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
}

output "ssh_public_key_path" {
  value = var.ssh_public_key_path
}

output "vm_ip" {
  value       = proxmox_virtual_environment_vm.debian_template.initialization[0].ip_config[0].ipv4[0].address
  description = "Adresse IP de la VM Debian_vm"
}