terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.70.0, <= 3.116.0"
    }
    ### provider for time_sleep workaround resource
    time = {
      source  = "hashicorp/time"
      version = "0.12.0"
    }
  }
  required_version = ">= 1.4.6"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
