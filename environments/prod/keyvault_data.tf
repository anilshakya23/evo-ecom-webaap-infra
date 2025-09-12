data "azurerm_key_vault" "prod-keyvault" {
  name                = "todokeyvault01"
  resource_group_name = "rg-anil"
}

data "azurerm_key_vault_secret" "prod-vm-username" {
  name         = "vm-user"
  key_vault_id = data.azurerm_key_vault.prod-keyvault.id
}

data "azurerm_key_vault_secret" "prod-vm-password" {
  name         = "vm-password"
  key_vault_id = data.azurerm_key_vault.prod-keyvault.id
}
