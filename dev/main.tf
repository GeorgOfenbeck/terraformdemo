# Configure the Azure provider
terraform {
  backend "azurerm" {
    resource_group_name  = "Terraform"
    storage_account_name = "innovationtfbackend"
    container_name       = "tfstate"
    key                  = "dev.cdrendpoint.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {
    key_vault {
      recover_soft_deleted_key_vaults = true
    }
  }
}


module "functionapp_with_storage"{
  source = "./../modules/azurem-function-app-storage"

  enviroment = "dev"
}