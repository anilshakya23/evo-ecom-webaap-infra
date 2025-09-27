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
  subscription_id = "51a6ae71-472e-4922-8df6-0a01fa72534d"
}