terraform {
   required_providers {
     azurerm = {
       source  = "hashicorp/azurerm"
       version = "~> 3.0"
     }
   }
   required_version = ">= 1.1.0"
 }
 
 provider "azurerm" {
   features {}
 }
 
 # Create a Resource Group
 resource "azurerm_resource_group" "rg_demo-rahul" {
   name     = "rg-tf-lab-diogus"
   location = "eastus"
 }
 
 # Create a Virtual Network + Subnet
 resource "azurerm_virtual_network" "vnet_demo-rahul" {
   name                = "vnet-tf-lab-diogus"
   location            = azurerm_resource_group.rg_demo-rahul.location
   resource_group_name = azurerm_resource_group.rg_demo-rahul.name
   address_space       = ["10.0.0.0/16"]
 }
 
 resource "azurerm_subnet" "subnet_demo-rahul" {
   name                 = "subnet-tf-lab-diogus"
   resource_group_name  = azurerm_resource_group.rg_demo-rahul.name
   virtual_network_name = azurerm_virtual_network.vnet_demo-rahul.name
   address_prefixes     = ["10.0.1.0/24"]
 }
 
 # Create a Network Interface
 resource "azurerm_network_interface" "nic_demo-rahul" {
   name                = "nic-tf-lab-diogus"
   location            = azurerm_resource_group.rg_demo-rahul.location
   resource_group_name = azurerm_resource_group.rg_demo-rahul.name
 
   ip_configuration {
     name                          = "ipconfig1"
     subnet_id                     = azurerm_subnet.subnet_demo-rahul.id
     private_ip_address_allocation = "Dynamic"
   }
 }
 
 # Create a Linux Virtual Machine
 resource "azurerm_linux_virtual_machine" "vm_demo-rahul" {
   name                = "vm-tf-lab-diogus"
   location            = azurerm_resource_group.rg_demo-rahul.location
   resource_group_name = azurerm_resource_group.rg_demo-rahul.name
   size                = "Standard_F2"
   admin_username      = "adminuserrahul"
 
   network_interface_ids = [azurerm_network_interface.nic_demo-rahul.id]
 
   admin_ssh_key {
     username   = "adminuserrahul"
     public_key = file(pathexpand("~/.ssh/azure_vm_key.pub"))
   }
 
   os_disk {
     caching              = "ReadWrite"
     storage_account_type = "Standard_LRS"
   }
 
   source_image_reference {
     publisher = "Canonical"
     offer     = "UbuntuServer"
     sku       = "18.04-LTS"
     version   = "latest"
   }
 }