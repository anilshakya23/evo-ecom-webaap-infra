data "azurerm_public_ip" "pip-basation-data" {
  name                = var.public_ip_basation_host
  resource_group_name = var.resource_group_name
}
