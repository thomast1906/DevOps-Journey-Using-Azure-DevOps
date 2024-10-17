terraform {
  required_version = ">= 1.9.6"
  backend "azurerm" {
    # resource_group_name  = "devopshardway-rg"
    # storage_account_name = "devopshardwaysa"
    # container_name       = "tfstate"
    # key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "04109105-f3ca-44ac-a3a7-66b4936112c3"

}
data "azurerm_client_config" "current" {}