# 🖥️ Infrastructure de Provisioning Multi-OS et Rôles (Templates & Clones)

Ce dépôt contient l’ensemble des configurations et scripts pour provisionner automatiquement différentes machines virtuelles à partir de templates Linux, ainsi que des clones spécialisés selon leur rôle (Kubernetes, BIND, Ansible, HAProxy…).

---

## 🗂️ Arborescence des Répertoires

| Dossier | Description |
|--------|-------------|
| `01-provision_template_ubuntu` | Provision d’un template Ubuntu (base pour clones) |
| `02-provision_template_debian` | Provision d’un template Debian |
| `03-provision_template_centos` | Provision d’un template CentOS |
| `05-provision_clone_centos_k8s` | Clone CentOS configuré comme nœud Kubernetes |
| `06-provision_clone_centos_worker` | Clone CentOS pour un worker K8s |
| `07-provision_clone_centos_HAproxy` | Clone CentOS configuré avec HAProxy |
| `08-provision_clone_centos_bind9` | Clone CentOS avec serveur DNS (BIND9) |
| `09-provision_clone_centos_ansible` | Clone CentOS utilisé comme nœud Ansible controller |
| `11-provision_lxc_debian` | Création de container LXC Debian |

---

## ⚙️ Technologies utilisées

- **Terraform** (si applicable pour l’orchestration)
- **KVM / LXC** (machines virtuelles ou conteneurs)

---

## 🚀 Comment démarrer

1. **Se placer dans le répertoire du template ou clone voulu :**
   ```bash
   cd 05-provision_clone_centos_k8s
