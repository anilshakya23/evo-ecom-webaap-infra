module "prod-rg" {
  source                  = "../../modules/azurerm_resource_group"
  resource_group_name     = "prod-evo-ecom-webapp-rg"
  resource_group_location = "East US"
}

module "prod-vnet" {
  depends_on               = [module.prod-rg]
  source                   = "../../modules/azurerm_vnet"
  virtual_network_name     = "prod-evo-ecom-webapp-vnet"
  address_space_type       = ["10.0.0.0/16"]
  resource_group_name      = "prod-evo-ecom-webapp-rg"
  virtual_network_location = "East US"
}

module "prod-subnet" {
  depends_on            = [module.prod-vnet]
  source                = "../../modules/azurerm_subnet"
  subnet_name           = "prod-evo-ecom-webapp-subnet"
  virtual_network_name  = "prod-evo-ecom-webapp-vnet"
  resource_group_name   = "prod-evo-ecom-webapp-rg"
  address_prefixes_type = ["10.0.1.0/24"]
}

module "prod-nsg-vm-1" {
    depends_on = [ module.prod-rg ]
  source                = "../../modules/azurerm_nsg"
  resource_nsg_name     = "prod-evo-ecom-webapp-nsg-1"
  resource_nsg_location = "East US"
  resource_group_name   = "prod-evo-ecom-webapp-rg"
}

module "prod-nsg-vm-2" {
    depends_on = [ module.prod-rg ]
  source                = "../../modules/azurerm_nsg"
  resource_nsg_name     = "prod-evo-ecom-webapp-nsg-2"
  resource_nsg_location = "East US"
  resource_group_name   = "prod-evo-ecom-webapp-rg"
}


module "prod-vm-1" {
  depends_on                     = [module.prod-rg, module.prod-vnet, module.prod-subnet, ]
  source                         = "../../modules/azurerm_vm"
  network_interface_name         = "prod-evo-ecom-webapp-nic-1"
  network_interface_location     = "East US"
  resource_group_name            = "prod-evo-ecom-webapp-rg"
  linux_virtual_machine_name     = "prod-evo-ecom-webapp-vm-1"
  linux_virtual_machine_location = "East US"
  admin_username_name            = data.azurerm_key_vault_secret.prod-vm-username.value
  admin_password_name            = data.azurerm_key_vault_secret.prod-vm-password.value
  subnet_name                    = "prod-evo-ecom-webapp-subnet"
  virtual_network_name           = "prod-evo-ecom-webapp-vnet"
  publisher_image                = "Canonical"
  offer_image                    = "0001-com-ubuntu-server-jammy"
  sku_image                      = "22_04-lts"
  version_image                  = "latest"
  resource_nsg_name              = "prod-evo-ecom-webapp-nsg-1"

}
module "prod-vm-2" {
  depends_on                     = [module.prod-rg, module.prod-vnet, module.prod-subnet, ]
  source                         = "../../modules/azurerm_vm"
  network_interface_name         = "prod-evo-ecom-webapp-nic-2"
  network_interface_location     = "East US"
  resource_group_name            = "prod-evo-ecom-webapp-rg"
  linux_virtual_machine_name     = "prod-evo-ecom-webapp-vm-2"
  linux_virtual_machine_location = "East US"
  admin_username_name            = data.azurerm_key_vault_secret.prod-vm-username.value
  admin_password_name            = data.azurerm_key_vault_secret.prod-vm-password.value
  subnet_name                    = "prod-evo-ecom-webapp-subnet"
  virtual_network_name           = "prod-evo-ecom-webapp-vnet"
  publisher_image                = "Canonical"
  offer_image                    = "0001-com-ubuntu-server-jammy"
  sku_image                      = "22_04-lts"
  version_image                  = "latest"
  resource_nsg_name              = "prod-evo-ecom-webapp-nsg-2"
}

module "prod-basation_host-pip" {
  depends_on             = [module.prod-rg]
  source                 = "../../modules/azurerm_public_ip"
  public_ip_name         = "prod-evo-ecom-webapp-basation-pip"
  resource_group_name    = "prod-evo-ecom-webapp-rg"
  public_ip_location     = "East US"
  allocation_method_type = "Static"
  sku_type               = "Standard"
}

module "prod-basation_host" {
  depends_on              = [module.prod-rg, module.prod-vnet, module.prod-subnet, module.prod-vm-1, module.prod-vm-2, module.prod-basation_host-pip]
  source                  = "../../modules/azurerm_bastion_host"
  bastion_host_name       = "prod-evo-ecom-webapp-basation-host"
  bastion_host_location   = "East US"
  resource_group_name     = "prod-evo-ecom-webapp-rg"
  virtual_network_name    = "prod-evo-ecom-webapp-vnet"
  public_ip_basation_host = "prod-evo-ecom-webapp-basation-pip"
}


module "prod-lb-pip" {
  depends_on             = [module.prod-rg]
  source                 = "../../modules/azurerm_public_ip"
  public_ip_name         = "prod-evo-ecom-webapp-lb-pip"
  resource_group_name    = "prod-evo-ecom-webapp-rg"
  public_ip_location     = "East US"
  allocation_method_type = "Static"
  sku_type               = "Standard"
}

module "prod-lb" {
  depends_on          = [module.prod-rg, module.prod-lb-pip, module.prod-vm-1, module.prod-vm-2]
  source              = "../../modules/azurerm_load_balancer"
  lb_name             = "prod-evo-ecom-webapp-lb"
  lb_location         = "East US"
  resource_group_name = "prod-evo-ecom-webapp-rg"
  public_ip_name      = "prod-evo-ecom-webapp-lb-pip"
}

module "prod-nic_lb_association-1" {
  depends_on                        = [module.prod-rg, module.prod-vnet, module.prod-subnet, module.prod-lb-pip, module.prod-lb, module.prod-vm-1, module.prod-vm-2]
  source                            = "../../modules/azurerm_lb_nic_association"
  network_interface_data            = "prod-evo-ecom-webapp-nic-1"
  resource_group_name               = "prod-evo-ecom-webapp-rg"
  lb_data_name                      = "prod-evo-ecom-webapp-lb"
  lb_backend_address_pool_data_name = "BackEndAddressPool"
  ip_configuration_name             = "internal"

}

module "prod-nic_lb_association-2" {
  depends_on                        = [module.prod-rg, module.prod-vnet, module.prod-subnet, module.prod-lb-pip, module.prod-lb, module.prod-vm-1, module.prod-vm-2]
  source                            = "../../modules/azurerm_lb_nic_association"
  network_interface_data            = "prod-evo-ecom-webapp-nic-2"
  resource_group_name               = "prod-evo-ecom-webapp-rg"
  lb_data_name                      = "prod-evo-ecom-webapp-lb"
  lb_backend_address_pool_data_name = "BackEndAddressPool"
  ip_configuration_name             = "internal"

}
