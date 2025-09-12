data "azurerm_network_interface" "nic-data" {
  name                = var.network_interface_data
  resource_group_name = var.resource_group_name
}

data "azurerm_lb" "lb-data" {
  name                = var.lb_data_name
  resource_group_name = var.resource_group_name
}

data "azurerm_lb_backend_address_pool" "lb-backend-pool-data" {
  name            = var.lb_backend_address_pool_data_name
  loadbalancer_id = data.azurerm_lb.lb-data.id
}


resource "azurerm_network_interface_backend_address_pool_association" "association" {
  network_interface_id    = data.azurerm_network_interface.nic-data.id
  ip_configuration_name   = var.ip_configuration_name
  backend_address_pool_id = data.azurerm_lb_backend_address_pool.lb-backend-pool-data.id
}