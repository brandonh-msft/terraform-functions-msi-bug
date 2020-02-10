#Set the terraform required version
terraform {
  required_version = ">= 0.12.6"
}

# Configure the Azure Provider
provider "azurerm" {
  # It is recommended to pin to a given version of the Provider
  version = "=1.42"
}

variable "prefix" {
  type = string
}

variable "sampleName" {
  type    = string
  default = "terraform-functions-msi-bug"
}

variable "location" {
  type    = string
  default = "West US 2"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags = {
    sample = var.sampleName
  }
}

resource "azurerm_storage_account" "fxnstor" {
  name                     = "${var.prefix}fxnssa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  tags = {
    sample = var.sampleName
  }
}

resource "azurerm_app_service_plan" "fxnapp" {
  name                = "${var.prefix}-fxn-asp"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "functionapp"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
  tags = {
    sample = var.sampleName
  }
}

resource "azurerm_function_app" "fxn" {
  name                      = "${var.prefix}-fxn"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
  app_service_plan_id       = azurerm_app_service_plan.fxnapp.id
  storage_connection_string = azurerm_storage_account.fxnstor.primary_connection_string
  version                   = "~2"
  tags = {
    sample = var.sampleName
  }
  # identity {
  #   type = "SystemAssigned"
  # }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }
}

# output "functionPrincipal" {
#   value = azurerm_function_app.identity[0].principal_id
# }
