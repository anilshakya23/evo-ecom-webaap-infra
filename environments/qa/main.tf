module "qa-rg" {
  source                  = "../../modules/azurerm_resource_group"
  resource_group_name     = "qa-evo-ecom-webapp-rg"
  resource_group_location = "East US"
}

module "qa-vnet" {
  depends_on               = [module.qa-rg]
  source                   = "../../modules/azurerm_vnet"
  virtual_network_name     = "qa-evo-ecom-webapp-vnet"
  address_space_type       = ["10.0.0.0/16"]
  resource_group_name      = "qa-evo-ecom-webapp-rg"
  virtual_network_location = "East US"
}

module "qa-subnet" {
  depends_on            = [module.qa-vnet]
  source                = "../../modules/azurerm_subnet"
  subnet_name           = "qa-evo-ecom-webapp-subnet"
  virtual_network_name  = "qa-evo-ecom-webapp-vnet"
  resource_group_name   = "qa-evo-ecom-webapp-rg"
  address_prefixes_type = ["10.0.1.0/24"]
}

module "qa-nsg-vm-1" {
    depends_on = [ module.qa-rg ]
  source                = "../../modules/azurerm_nsg"
  resource_nsg_name     = "qa-evo-ecom-webapp-nsg-1"
  resource_nsg_location = "East US"
  resource_group_name   = "qa-evo-ecom-webapp-rg"
}

module "qa-nsg-vm-2" {
    depends_on = [ module.qa-rg ]
  source                = "../../modules/azurerm_nsg"
  resource_nsg_name     = "qa-evo-ecom-webapp-nsg-2"
  resource_nsg_location = "East US"
  resource_group_name   = "qa-evo-ecom-webapp-rg"
}


module "qa-vm-1" {
  depends_on                     = [module.qa-rg, module.qa-vnet, module.qa-subnet, ]
  source                         = "../../modules/azurerm_vm"
  network_interface_name         = "qa-evo-ecom-webapp-nic-1"
  network_interface_location     = "East US"
  resource_group_name            = "qa-evo-ecom-webapp-rg"
  linux_virtual_machine_name     = "qa-evo-ecom-webapp-vm-1"
  linux_virtual_machine_location = "East US"
  admin_username_name            = data.azurerm_key_vault_secret.qa-vm-username.value
  admin_password_name            = data.azurerm_key_vault_secret.qa-vm-password.value
  subnet_name                    = "qa-evo-ecom-webapp-subnet"
  virtual_network_name           = "qa-evo-ecom-webapp-vnet"
  publisher_image                = "Canonical"
  offer_image                    = "0001-com-ubuntu-server-jammy"
  sku_image                      = "22_04-lts"
  version_image                  = "latest"
  resource_nsg_name              = "qa-evo-ecom-webapp-nsg-1"

}
module "qa-vm-2" {
  depends_on                     = [module.qa-rg, module.qa-vnet, module.qa-subnet, ]
  source                         = "../../modules/azurerm_vm"
  network_interface_name         = "qa-evo-ecom-webapp-nic-2"
  network_interface_location     = "East US"
  resource_group_name            = "qa-evo-ecom-webapp-rg"
  linux_virtual_machine_name     = "qa-evo-ecom-webapp-vm-2"
  linux_virtual_machine_location = "East US"
  admin_username_name            = data.azurerm_key_vault_secret.qa-vm-username.value
  admin_password_name            = data.azurerm_key_vault_secret.qa-vm-password.value
  subnet_name                    = "qa-evo-ecom-webapp-subnet"
  virtual_network_name           = "qa-evo-ecom-webapp-vnet"
  publisher_image                = "Canonical"
  offer_image                    = "0001-com-ubuntu-server-jammy"
  sku_image                      = "22_04-lts"
  version_image                  = "latest"
  resource_nsg_name              = "qa-evo-ecom-webapp-nsg-2"
}

module "qa-basation_host-pip" {
  depends_on             = [module.qa-rg]
  source                 = "../../modules/azurerm_public_ip"
  public_ip_name         = "qa-evo-ecom-webapp-basation-pip"
  resource_group_name    = "qa-evo-ecom-webapp-rg"
  public_ip_location     = "East US"
  allocation_method_type = "Static"
  sku_type               = "Standard"
}

module "qa-basation_host" {
  depends_on              = [module.qa-rg, module.qa-vnet, module.qa-subnet, module.qa-vm-1, module.qa-vm-2, module.qa-basation_host-pip]
  source                  = "../../modules/azurerm_bastion_host"
  bastion_host_name       = "qa-evo-ecom-webapp-basation-host"
  bastion_host_location   = "East US"
  resource_group_name     = "qa-evo-ecom-webapp-rg"
  virtual_network_name    = "qa-evo-ecom-webapp-vnet"
  public_ip_basation_host = "qa-evo-ecom-webapp-basation-pip"
}


module "qa-lb-pip" {
  depends_on             = [module.qa-rg]
  source                 = "../../modules/azurerm_public_ip"
  public_ip_name         = "qa-evo-ecom-webapp-lb-pip"
  resource_group_name    = "qa-evo-ecom-webapp-rg"
  public_ip_location     = "East US"
  allocation_method_type = "Static"
  sku_type               = "Standard"
}

module "qa-lb" {
  depends_on          = [module.qa-rg, module.qa-lb-pip, module.qa-vm-1, module.qa-vm-2]
  source              = "../../modules/azurerm_load_balancer"
  lb_name             = "qa-evo-ecom-webapp-lb"
  lb_location         = "East US"
  resource_group_name = "qa-evo-ecom-webapp-rg"
  public_ip_name      = "qa-evo-ecom-webapp-lb-pip"
}

module "qa-nic_lb_association-1" {
  depends_on                        = [module.qa-rg, module.qa-vnet, module.qa-subnet, module.qa-lb-pip, module.qa-lb, module.qa-vm-1, module.qa-vm-2]
  source                            = "../../modules/azurerm_lb_nic_association"
  network_interface_data            = "qa-evo-ecom-webapp-nic-1"
  resource_group_name               = "qa-evo-ecom-webapp-rg"
  lb_data_name                      = "qa-evo-ecom-webapp-lb"
  lb_backend_address_pool_data_name = "BackEndAddressPool"
  ip_configuration_name             = "internal"

}

module "qa-nic_lb_association-2" {
  depends_on                        = [module.qa-rg, module.qa-vnet, module.qa-subnet, module.qa-lb-pip, module.qa-lb, module.qa-vm-1, module.qa-vm-2]
  source                            = "../../modules/azurerm_lb_nic_association"
  network_interface_data            = "qa-evo-ecom-webapp-nic-2"
  resource_group_name               = "qa-evo-ecom-webapp-rg"
  lb_data_name                      = "qa-evo-ecom-webapp-lb"
  lb_backend_address_pool_data_name = "BackEndAddressPool"
  ip_configuration_name             = "internal"

}

