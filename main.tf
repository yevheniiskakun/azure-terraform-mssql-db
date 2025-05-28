data "azurerm_client_config" "current" {}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_resource_group" "mssql-rg" {
  name     = "mssql-db-resources"
  location = var.location
}


resource "azurerm_key_vault" "mssql-kv" {
  name                       = "mssql-key-vault"
  location                   = azurerm_resource_group.mssql-rg.location
  resource_group_name        = azurerm_resource_group.mssql-rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  enable_rbac_authorization = true # https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli

}

resource "azurerm_key_vault_secret" "mssql-server-login" {
  name         = "mssql-server-login"
  value        = var.server_admin_login
  key_vault_id = azurerm_resource_group.mssql-rg.id
}

resource "azurerm_key_vault_secret" "mssql-server-password" {
  name         = "mssql-server-password"
  value        = random_password.password.result
  key_vault_id = azurerm_resource_group.mssql-rg.id
}

