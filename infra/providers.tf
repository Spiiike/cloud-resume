terraform {
  required_version = ">=1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate800573"
    container_name       = "tfstate"
    key                  = "cloud-resume.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}

  storage_use_azuread = true
}