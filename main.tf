data "azurerm_client_config" "current" {}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_pet" "name" {
  
}

resource "azurerm_resource_group" "mssql-rg" {
  name     = "mssql-db-resources"
  location = var.location
}


resource "azurerm_key_vault" "mssql-kv" {
  name                       = "kv-${random_pet.name.id}"
  location                   = azurerm_resource_group.mssql-rg.location
  resource_group_name        = azurerm_resource_group.mssql-rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  enable_rbac_authorization = true # Do not forgot to add yourself one of the roles: https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli

}

resource "azurerm_key_vault_secret" "mssql-server-login" {
  name         = "mssql-server-login"
  value        = var.server_admin_login
  key_vault_id = azurerm_key_vault.mssql-kv.id
}

resource "azurerm_key_vault_secret" "mssql-server-password" {
  name         = "mssql-server-password"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.mssql-kv.id
}

resource "azurerm_mssql_server" "mssql" {
  name                         = "sqlserver-${random_pet.name.id}"
  resource_group_name          = azurerm_resource_group.mssql-rg.name
  location                     = azurerm_resource_group.mssql-rg.location
  version                      = "12.0"

  administrator_login          = azurerm_key_vault_secret.mssql-server-login.value
  administrator_login_password = azurerm_key_vault_secret.mssql-server-password.value
}

resource "azurerm_mssql_database" "mssql-db" {
  name         = "db-${random_pet.name.id}"
  server_id    = azurerm_mssql_server.mssql.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}
