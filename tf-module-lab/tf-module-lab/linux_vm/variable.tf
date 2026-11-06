variable "vm_name" {
  description = "Name of the virtual machine"
}
 
variable "location" {
  description = "Azure region for the VM"
}
 
variable "rg_name" {
  description = "Resource group name for the VM"
}
 
variable "vm_size" {
  description = "Size of the VM"
  default     = "Standard_B1s"
}
 
variable "admin_username" {
  description = "Admin username for the VM"
}
 
variable "nic_id" {
  description = "ID of the network interface to attach to the VM"
}
 
variable "admin_ssh_public_key" {
  description = "SSH public key for Linux VM authentication"
  type        = string
}