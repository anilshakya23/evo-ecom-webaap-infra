data "azurerm_key_vault" "dev-keyvault" {
  name                = "todokeyvault01"
  resource_group_name = "rg-anil"
}

data "azurerm_key_vault_secret" "dev-vm-username" {
  name         = "vm-user"
  key_vault_id = data.azurerm_key_vault.dev-keyvault.id
}

data "azurerm_key_vault_secret" "dev-vm-password" {
  name         = "vm-password"
  key_vault_id = data.azurerm_key_vault.dev-keyvault.id
}
