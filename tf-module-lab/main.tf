# 1. Generate SSH key
resource "tls_private_key" "ssh_rahul" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
 
# 2. Create Resource Group
resource "azurerm_resource_group" "rg_demo_rahul" {
  name     = "rg-mod-lab-vm-rahul"
  location = "eastus"
}
 
# 3. Create VNet, Subnet, NIC
resource "azurerm_virtual_network" "vnet_rahul" {
  name                = "vnet-mod-lab-rahul"
  location            = azurerm_resource_group.rg_demo_rahul.location
  resource_group_name = azurerm_resource_group.rg_demo_rahul.name
  address_space       = ["10.0.0.0/16"]
}
 
resource "azurerm_subnet" "subnet_rahul" {
  name                 = "subnet-mod-lab-rahul"
  resource_group_name  = azurerm_resource_group.rg_demo_rahul.name
  virtual_network_name = azurerm_virtual_network.vnet_rahul.name
  address_prefixes     = ["10.0.1.0/24"]
}
 
resource "azurerm_network_interface" "nic_rahul" {
  name                = "nic-mod-lab-rahul"
  location            = azurerm_resource_group.rg_demo_rahul.location
  resource_group_name = azurerm_resource_group.rg_demo_rahul.name
 
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet_rahul.id
    private_ip_address_allocation = "Dynamic"
  }
}
 
# 4. Call the module to deploy the Linux VM
module "linux_vm" {
  source               = "./modules/linux_vm"
  vm_name              = "vm-lab-module"
  location             = azurerm_resource_group.rg_demo_rahul.location
  rg_name              = azurerm_resource_group.rg_demo_rahul.name
  vm_size              = "Standard_B1s"
  admin_username       = "azureuser"
  admin_ssh_public_key = tls_private_key.ssh_rahul.public_key_openssh
  nic_id               = azurerm_network_interface.nic_rahul.id
}
 
# 5. Output the SSH private key from TLS
output "ssh_private_key" {
  value     = tls_private_key.ssh_rahul.private_key_pem
  sensitive = true
}
 
# 6. Write the private key to a local file with 0600 permissions
resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh_rahul.private_key_pem
  filename        = "${path.module}/ssh_private_key.pem"
  file_permission = "0600"
}