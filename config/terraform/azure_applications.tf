resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${local.scope}-${local.app_name}-app-service-plan"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  // must be kind="Linux" and reserved=true in order to run Linux containers
  kind     = "Linux"
  reserved = true
  sku {
    // must be Premium-tier in order to work with Azure Private Link (for DB)
    tier = "PremiumV2"
    size = "P1v2" // or P2v2 or P3v2
  }
}
resource "azurerm_app_service" "app_service" {
  name                = "${local.scope}-${local.app_name}-app-service"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  identity {
    type = "SystemAssigned"
  }
  site_config {
    vnet_route_all_enabled = true
    linux_fx_version       = "DOCKER|${local.docker_image_name}"
    ftps_state             = "Disabled"
  }

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL          = local.registry_url
    DOCKER_REGISTRY_SERVER_USERNAME     = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = azurerm_container_registry.acr.admin_password
    DOCKER_CUSTOM_IMAGE_NAME            = local.docker_image_name
    DATABASE_URL                        = var.DATABASE_URL_FOR_STAGING
    RAILS_MASTER_KEY                    = var.RAILS_MASTER_KEY
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
  }
  logs {
    // http_logs seems to be the Azure App Service-level logs, external to our app
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 100
      }
    }
    // application_logs seems to mean logs from our actual app code in its container
    application_logs {
      file_system_level = "Verbose"
    }
  }
}

resource "azurerm_app_service_slot" "benchmarks_staging_slot" {
  name                = "staging"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_service_name    = azurerm_app_service.app_service.name
  app_settings = {
    DOCKER_ENABLE_CI                    = true // special //
    DOCKER_REGISTRY_SERVER_URL          = local.registry_url
    DOCKER_REGISTRY_SERVER_USERNAME     = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = azurerm_container_registry.acr.admin_password
    DOCKER_CUSTOM_IMAGE_NAME            = local.docker_image_name
    DATABASE_URL                        = var.DATABASE_URL_FOR_STAGING
    RAILS_MASTER_KEY                    = var.RAILS_MASTER_KEY
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
  }
}
