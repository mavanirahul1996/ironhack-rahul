variable "vnet_name" {}
variable "location" {}
variable "rg_name" {}
variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}
variable "subnetA_name" {}
variable "subnetA_prefix" {}
variable "subnetB_name" {}
variable "subnetB_prefix" {}