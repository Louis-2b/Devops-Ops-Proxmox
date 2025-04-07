# Déclaration d'une ressource pour créer un conteneur LXC sur Proxmox
resource "proxmox_virtual_environment_container" "debian_container" {
  description = "lxc_test"            # Description du conteneur
  vm_id         = var.vm_id           # Identifiant unique du conteneur
  node_name     = var.node_name       # Nœud Proxmox où le conteneur sera créé
  unprivileged  = true                # Conteneur non privilégié (plus sécurisé)
  tags          = ["debian", "infra"] # Tags pour organiser le conteneur
  start_on_boot = true                # Démarrer automatiquement au démarrage de l'hôte

  # -- 🖥️ Paramètres Matériels
  cpu {
    cores        = 1       # Nombre de cœurs CPU
    architecture = "amd64" # Architecture du processeur
  }

  # Configuration de la mémoire
  memory {
    dedicated = 1024 # Mémoire RAM dédiée (en Mo)
    swap      = 512  # Ajout de swap raisonnable
  }

  # -- 🌐 Paramètres Réseau 
  network_interface {
    name       = "vmbr0" # Pont réseau à utiliser
  }

  # Configuration des fonctionnalités du conteneur
  features {
    nesting = true  # Activer le nesting (pour exécuter des conteneurs dans un conteneur)
  }

  # -- 💾 Paramètres Stockage principal
  disk {
    datastore_id = var.datastore_id # Datastore pour le disque
    size         = 20               # Taille du disque (en Go)
  }

  # -- 📡Configuration du système d'exploitation
  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.latest_debian_lxc_img.id # ID du template
    # Ou vous pouvez utiliser un ID de volume, obtenu via une commande "pvesm list <storage>"
    # template_file_id = "local:vztmpl/jammy-server-cloudimg-amd64.tar.gz"
    type             = "debian"                                                # Type de système d'exploitation
  }
  
  # Montage de type "bind mount" (nécessite privilèges root@pam)
  #mount_point {
    #volume = "/mnt/bindmounts/shared"  # Chemin source sur l'hôte
    #path   = "/mnt/shared"  # Chemin cible dans le conteneur
  #}
  
  # Montage de type "volume mount" (nouveau volume créé par Proxmox)
  mount_point {
    volume = "local-lvm"  # Datastore pour le volume
    size   = "10G"  # Taille allouée
    path   = "/mnt/volume"  # Chemin dans le conteneur
  }

  # -- 📡Configuration de Cloud-Init
  initialization {
    hostname = "debian-container"  # Nom d'hôte du conteneur

    ip_config {
      ipv4 {
        address = "192.168.222.50/24" # Adresse IP statique
        gateway = "192.168.222.2"     # Passerelle par défaut
      }
    }

    dns {
      domain  = "localdomain"                # Ajouté pour une résolution complète
      servers = ["192.168.222.2", "8.8.8.8"] # DNS primaire + secours
    }
    
    user_account {
      password = var.ci_password
      keys     = [file(var.ssh_public_key_path)] # Clé publique pour SSH dans la VM



      # password = random_password.ubuntu_container_password.result # Mot de passe aléatoire
      # keys = [
        #trimspace(tls_private_key.ubuntu_container_key.public_key_openssh)
      #] # Clé publique SSH
    }
  }
  
  # Configuration du démarrage du conteneur
  startup {
    order      = "3"  # Ordre de démarrage
    up_delay   = "60"  # Délai avant de démarrer (en secondes)
    down_delay = "60"  # Délai avant d'arrêter (en secondes)
  }
}


# Déclaration d'une ressource pour télécharger un template LXC sur Proxmox
resource "proxmox_virtual_environment_download_file" "latest_debian_lxc_img" {
  content_type = "vztmpl"         # Type de contenu (template LXC)
  datastore_id = "local" # Datastore où le template sera stocké
  node_name    = var.node_name    # Nœud Proxmox où le template sera téléchargé
  url          = "http://download.proxmox.com/images/system/debian-12-standard_12.7-1_amd64.tar.zst"
}


output "ci_password" {
  value     = var.ci_password
  sensitive = true
}

output "ssh_private_key_path" {
  value     = var.ssh_private_key_path
  sensitive = true
}

output "ssh_public_key_path" {
  value = var.ssh_public_key_path
}

output "vm_ip" {
  value       = proxmox_virtual_environment_container.debian_container.initialization[0].ip_config[0].ipv4[0].address
  description = "Adresse IP de la VM Ubuntu_container"
}



# Déclaration d'une ressource pour générer un mot de passe aléatoire
#resource "random_password" "ubuntu_container_password" {
  #length           = 16    # Longueur du mot de passe
  #special          = true  # Inclure des caractères spéciaux
  #override_special = "_%@" # Caractères spéciaux autorisés
  #min_upper        = 1     # Ajouté: minimum de majuscules
  #min_numeric      = 2     # Ajouté: minimum de chiffres
  #min_special      = 2     # Ajouté: minimum de caractères spéciaux
#}

# Déclaration d'une ressource pour générer une paire de clés SSH
#resource "tls_private_key" "ubuntu_container_key" {
  #algorithm = "RSA"
  #rsa_bits  = 2048
#}

# Sortie du mot de passe généré (sensible)
#output "ubuntu_container_password" {
  #value     = random_password.ubuntu_container_password.result
  #sensitive = true
#}

# Sortie de la clé privée générée (sensible)
#output "ubuntu_container_private_key" {
  #value     = tls_private_key.ubuntu_container_key.private_key_pem
  #sensitive = true
#}

# Sortie de la clé publique générée
#output "ubuntu_container_public_key" {
  #value = tls_private_key.ubuntu_container_key.public_key_openssh
#}