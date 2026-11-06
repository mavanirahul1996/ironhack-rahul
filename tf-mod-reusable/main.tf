terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  required_version = ">=1.1.0"
}
 
provider "azurerm" {
  features {}
}
 
resource "azurerm_resource_group" "rg_demo" {
  name     = "rg-reuse-mod-lab"
  location = "eastus"
}
 
module "my_network_bundle" {
  source          = "./modules/network_bundle"
  vnet_name       = "vnet-reuse-lab"
  location        = azurerm_resource_group.rg_demo.location
  rg_name         = azurerm_resource_group.rg_demo.name
  address_space   = ["10.10.0.0/16"]
  subnetA_name    = "frontend-subnet"
  subnetA_prefix  = "10.10.1.0/24"
  subnetB_name    = "backend-subnet"
  subnetB_prefix  = "10.10.2.0/24"
}