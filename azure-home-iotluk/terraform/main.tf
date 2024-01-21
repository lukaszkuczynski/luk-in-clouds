# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

resource "azurerm_resource_group" "functionapp_resource_group" {
  name     = "rg-home-iotluk-functionapps"
  location = var.location_name

}


resource "azurerm_storage_account" "storage_account" {
  name                     = "iotlukstorage${var.env_name}"
  resource_group_name      = azurerm_resource_group.functionapp_resource_group.name
  location                 = azurerm_resource_group.functionapp_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "service_plan" {
  name                = "home-iotluk-app-service-plan"
  resource_group_name = azurerm_resource_group.functionapp_resource_group.name
  location            = azurerm_resource_group.functionapp_resource_group.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_application_insights" "appinsights" {
  name                = "home-iotluk-appinsights"
  location            = azurerm_resource_group.functionapp_resource_group.location
  resource_group_name = azurerm_resource_group.functionapp_resource_group.name
  application_type    = "web"
}

resource "azurerm_linux_function_app" "function_app" {
  name                = var.function_app_name
  resource_group_name = azurerm_resource_group.functionapp_resource_group.name
  location            = azurerm_resource_group.functionapp_resource_group.location

  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.service_plan.id

  site_config {
    application_stack {
      python_version = "3.9"
    }
    application_insights_key               = azurerm_application_insights.appinsights.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.appinsights.connection_string
  }

  app_settings = {
    AzureWebJobsFeatureFlags = "EnableWorkerIndexing"
  }

}

resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = var.cosmosdb_account
  location            = azurerm_resource_group.functionapp_resource_group.location
  resource_group_name = azurerm_resource_group.functionapp_resource_group.name
  offer_type          = "Standard"
  # kind                = "MongoDB"

  enable_automatic_failover = false

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  # geo_location {
  #   location          = "eastus"
  #   failover_priority = 1
  # }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "cosmosdb_database" {
  name                = "HomeIotLuk"
  resource_group_name = azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
}

resource "azurerm_cosmosdb_sql_container" "cosmosdb_container" {
  name                = "Events"
  resource_group_name = azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_sql_database.cosmosdb_database.name
  partition_key_path  = "/EventId"
}

output "function_app_name" {
  value = azurerm_linux_function_app.function_app.name
}
