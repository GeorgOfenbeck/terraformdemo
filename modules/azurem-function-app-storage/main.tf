
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     =  "${var.resource_group_name}_${var.enviroment}"
  location = "switzerlandnorth"
}


resource "azurerm_key_vault" "key_vault" {
  name                        = "${var.keyvault_name}${var.enviroment}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "storagekeyvaultaccess" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_storage_account.storage_account.identity.0.principal_id

  key_permissions    = ["get", "create", "list", "restore", "recover", "unwrapkey", "wrapkey", "purge", "encrypt", "decrypt", "sign", "verify"]
  secret_permissions = ["get"]
}

resource "azurerm_key_vault_access_policy" "client" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions    = ["get", "create", "delete", "list", "restore", "recover", "unwrapkey", "wrapkey", "purge", "encrypt", "decrypt", "sign", "verify"]
  secret_permissions = ["get"]
}

resource "azurerm_key_vault_key" "storageencryptionkey" {
  name         = var.storage_encryption_key_name
  key_vault_id = azurerm_key_vault.key_vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  depends_on = [
    azurerm_key_vault_access_policy.client,
    azurerm_key_vault_access_policy.storagekeyvaultaccess,
  ]
}


resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.storage_name}${var.enviroment}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"


  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_account_customer_managed_key" "storage_custommanaged_key" {
  storage_account_id = azurerm_storage_account.storage_account.id
  key_vault_id       = azurerm_key_vault.key_vault.id
  key_name           = azurerm_key_vault_key.storageencryptionkey.name
}

resource "azurerm_storage_container" "storage_container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

resource "azurerm_app_service_plan" "service_plan" {
  name                = "${var.service_plan_name}_${var.enviroment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}



resource "azurerm_function_app" "function_app" {
  name                       = "${var.function_app_name}${var.enviroment}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.service_plan.id
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  https_only                 = true
  client_cert_mode           = "Required"
  version                    = "3"

  site_config {
    http2_enabled   = true
    java_version    = "1.8"
    min_tls_version = "1.2"
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"  = "java"
    "WEBSITE_RUN_FROM_PACKAGE"  = "1"
    "Storage_Connection_String" = (azurerm_storage_account.storage_account.primary_blob_connection_string)
    "Storage_Container"         = (azurerm_storage_container.storage_container.name)
  }

}


