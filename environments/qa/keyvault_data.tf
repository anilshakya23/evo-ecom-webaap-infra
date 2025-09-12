data "azurerm_key_vault" "qa-keyvault" {
  name                = "todokeyvault01"
  resource_group_name = "rg-anil"
}

data "azurerm_key_vault_secret" "qa-vm-username" {
  name         = "vm-user"
  key_vault_id = data.azurerm_key_vault.qa-keyvault.id
}

data "azurerm_key_vault_secret" "qa-vm-password" {
  name         = "vm-password"
  key_vault_id = data.azurerm_key_vault.qa-keyvault.id
}
