terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.70.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.19.1"
    }
  }

  required_version = ">= 1.4.6"
}
