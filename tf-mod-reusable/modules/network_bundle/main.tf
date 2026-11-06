
resource "azurerm_virtual_network" "vnet_rahul" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = var.address_space
}

resource "azurerm_subnet" "subnetA_rahul" {
  name                 = var.subnetA_name
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet_rahul.name
  address_prefixes     = [var.subnetA_prefix]
}

resource "azurerm_subnet" "subnetB_rahul" {
  name                 = var.subnetB_name
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet_rahul.name
  address_prefixes     = [var.subnetB_prefix]
}