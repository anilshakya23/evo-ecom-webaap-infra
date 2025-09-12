resource "azurerm_public_ip" "lb-pip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.public_ip_location
  allocation_method   = var.allocation_method_type
  sku                 = var.sku_type
}

