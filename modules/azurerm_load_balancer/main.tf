resource "azurerm_lb" "todo-lb" {
  name                = var.lb_name
  location            = var.lb_location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = data.azurerm_public_ip.lb-pip-data.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb-pool" {
  loadbalancer_id = azurerm_lb.todo-lb.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "lb-probe" {
  loadbalancer_id = azurerm_lb.todo-lb.id
  name            = "lb-probe"
  port            = 22
}

resource "azurerm_lb_rule" "lb-pule" {
  loadbalancer_id                = azurerm_lb.todo-lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
}