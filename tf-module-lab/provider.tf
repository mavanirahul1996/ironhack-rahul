terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~>2.1"
    }
  }
  required_version = ">=1.1.0"
}
 
provider "azurerm" {
  features {}
  # Replace with your subscription if needed.
  subscription_id = "daf9c53c-7096-4293-9bb1-f7ad8263db1a"
}