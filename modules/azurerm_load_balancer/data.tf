data "azurerm_public_ip" "lb-pip-data" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
}