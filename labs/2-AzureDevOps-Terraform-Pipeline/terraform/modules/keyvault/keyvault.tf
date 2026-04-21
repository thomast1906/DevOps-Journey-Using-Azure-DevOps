data "azurerm_resource_group" "keyvault" {
  name = "${var.name}-rg"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                        = "${var.name}-kv"
  location                    = data.azurerm_resource_group.keyvault.location
  resource_group_name         = data.azurerm_resource_group.keyvault.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enable_rbac_authorization   = true

  sku_name = "standard"
}

resource "azurerm_role_assignment" "keyvault_admin" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.admin_object_id
}