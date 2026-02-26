# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.38.1 "
    }
    # random = {
    #   source = "hashicorp/random"
    #   version = "=3.7.2 "
    # }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  resource_provider_registrations = "none"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Generate a random password for the VM admin users
resource "random_password" "pwd" {
  length  = 16
  special = true
  lower   = true
  upper   = true
  numeric = true
}
