terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.43.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-anil"
    storage_account_name = "stanilshakya"
    container_name       = "anilcontainer"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "51984565-3b14-41c7-900f-cf01ff601798"
}