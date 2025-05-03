variable "cloud_id" {
  type        = string
  description = "Cloud ID"
}

variable "folder_id" {
  type        = string
  description = "Folder ID"
}

variable "token" {
  type        = string
  description = "OAuth token"
  sensitive   = true
}

variable "zone" {
  type        = string
  default     = "ru-central1-a"
  description = "Availability zone"
}

variable "network_name" {
  type        = string
  default     = "default"
  description = "Network name"
}

variable "subnet_name" {
  type        = string
  default     = "default-ru-central1-a"
  description = "Subnet name"
}

variable "vm_user" {
  type        = string
  default     = "ubuntu"
  description = "Username for VM instances"
}

variable "instance_resources" {
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    cores         = 2
    memory        = 4
    core_fraction = 100
  }
  description = "Default resources for instances"
}

variable "disk_sizes" {
  description = "Disk sizes for different instance types"
  type        = map(number)
  default     = {
    frontend   = 20
    database   = 30
    monitoring = 20
    zabbix     = 20
  }
}

variable "db_password" {
  type        = string
  description = "PostgreSQL database password"
}

variable "ssh_key" {
  type        = string
  description = "SSH public key for instance access"
} 