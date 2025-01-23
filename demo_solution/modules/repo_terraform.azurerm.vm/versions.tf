terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.35.0, <= 3.116.0"
    }
  }

  required_version = ">= 1.4.6"
}
