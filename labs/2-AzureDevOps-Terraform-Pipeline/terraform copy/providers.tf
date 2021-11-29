provider "azurerm" {
    version = "~> 2.0"
    features {}
}

terraform {
    backend "azurerm" {
      resource_group_name = "devops-journey-rg"   
      storage_account_name = "devopsjourneyazuredevops"
      container_name = "tfstate"
    }
}