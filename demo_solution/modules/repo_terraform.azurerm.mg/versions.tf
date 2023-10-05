terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.35.0"
    }
  }

  required_version = ">= 1.1.8"
}