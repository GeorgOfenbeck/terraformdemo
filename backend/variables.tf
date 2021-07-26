
variable "resource_group_name" {
  type = string
  default = "Terraform"
  description = "Name of the resource group"
}

variable "keyvault_name" {
    type = string
    description = "Name of the key vault used to store the storage encryption key"
}

variable "storage_encryption_key_name" {
  type = string
  default = "storage-encryption-key"
  description = "Name of the key used to encrypt the storage"
}

variable "storage_name" {
  type = string
  default = "innovationtfbackend"
  description = "Name of the storage"
}


variable "container_name" {
  type = string
  default = "tfstate"
  description = "Name of (blob) container used inside the storage"
}