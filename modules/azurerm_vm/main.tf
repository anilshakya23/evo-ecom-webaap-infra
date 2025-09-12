resource "azurerm_network_interface_security_group_association" "vm1_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = data.azurerm_network_security_group.nsg-data.id
}

data "azurerm_network_security_group" "nsg-data" {
  name                = var.resource_nsg_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_interface" "nic" {
  name                = var.network_interface_name
  location            = var.network_interface_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.linux_virtual_machine_name
  resource_group_name             = var.resource_group_name
  location                        = var.linux_virtual_machine_location
  size                            = "Standard_F2"
  admin_username                  = var.admin_username_name
  admin_password                  = var.admin_password_name
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.publisher_image
    offer     = var.offer_image
    sku       = var.sku_image
    version   = var.version_image
  }
  
   custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
  EOF
  )
}
