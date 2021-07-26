

variable "enviroment" {
  type = string
  description = "will be used as a postfix for all variable names (e.g. prod/stage/int)"
}

variable "resource_group_name" {
  type = string
  default = "CDRRestEndpoint_"
  description = "Name of the resource group"
}

variable "keyvault_name" {
    type = string
    default = "hltkeyvault"
    description = "Name of the key vault used to store the storage encryption key"
}

variable "storage_encryption_key_name" {
  type = string
  default = "storage-encryption-key"
  description = "Name of the key used to encrypt the storage"
}

variable "storage_name" {
  type = string
  default = "storagename"
  description = "Name of the storage"
}


variable "container_name" {
  type = string
  default = "storagename"
  description = "Name of (blob) container used inside the storage"
}

variable "service_plan_name" {
  type = string
  default = "service-plan"
}


variable "function_app_name" {
  type = string
  default = "cdrrestendpoint"
}