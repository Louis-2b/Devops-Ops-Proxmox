variable "api_token" {
  type = string
}

variable "endpoint" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "node_name" {
  type = string
}

variable "datastore_id" {
  type = string
}

variable "ci_user" {
  type = string
}

variable "ci_password" {
  type = string
  sensitive = true
}

variable "ssh_private_key_path" {
  type        = string
}

variable "ssh_public_key_path" {
  type        = string
}