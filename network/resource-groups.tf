resource "azurerm_resource_group" "hub-rg" {
  location = var.location
  name     = "rg-hub-vnet-${var.product-name}"
  tags     = var.tags
}

resource "azurerm_resource_group" "spoke-01-rg" {
  location = var.location
  name     = "spoke-01-vnet-${var.product-name}-rg"
  tags     = var.tags
}

resource "azurerm_resource_group" "spoke-02-rg" {
  location = var.location
  name     = "spoke-02-vnet-${var.product-name}-rg"
  tags     = var.tags
}

resource "azurerm_resource_group" "spoke-03-rg" {
  location = var.location
  name     = "spoke-03-vnet-${var.product-name}-rg"
  tags     = var.tags
}

resource "azurerm_resource_group" "keyvault-rg" {
  location = var.location
  name     = "keyvault-${var.product-name}-rg"
  tags     = var.tags
}

resource "azurerm_resource_group" "web-app-rg" {
  location = var.location
  name     = "web-app-${var.product-name}-rg"
  tags     = var.tags
}

resource "azurerm_resource_group" "vms-rg" {
  location = var.location
  name     = "vms-${var.product-name}-rg"
  tags     = var.tags
}

resource "azurerm_resource_group" "law-rg" {
  location = var.location
  name     = "law-${var.product-name}-rg"
  tags     = var.tags
}

resource "azurerm_resource_group" "network-watcher-rg" {
  location = var.location
  name     = "network-watcher-${var.product-name}-rg"
  tags     = var.tags
}
