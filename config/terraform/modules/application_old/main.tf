resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${local.app_service_name}-app-service-plan"
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
  # This name becomes a subdomain in a globally accessible URL, so must be globally unique
  name                = local.app_service_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_settings        = merge(local.app_settings, { DATABASE_URL = local.production_database_url })
  identity {
    type = "SystemAssigned"
  }
  site_config {
    always_on              = true
    vnet_route_all_enabled = true
    linux_fx_version       = "DOCKER|${local.docker_image_name}"
    ftps_state             = "Disabled"
    health_check_path      = "/healthcheck"
  }
  auth_settings {
    enabled                       = true
    runtime_version               = "~1"
    additional_login_params       = { scope = "openid email" }
    unauthenticated_client_action = "AllowAnonymous"
    active_directory {
      client_id = local.production_aad_client_id
      #client_secret = ""
    }
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
  lifecycle {
    ignore_changes = [
      # Ignore changes because deploys change which tag is deployed
      site_config["linux_fx_version"],
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"],
    ]
  }
}

module "application_slot" "preview" {
  source              = "../application_slot"
  name                = "preview"
  resource_group_name = local.resource_group_name
  app_service_name    = local.app_service_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  docker_image_name   = local.docker_image_name
  aad_client_id       = local.production_aad_client_id
  app_settings        = merge(local.app_settings, { DATABASE_URL = local.production_database_url })
}

module "application_slot" "staging" {
  source              = "../application_slot"
  name                = "staging"
  resource_group_name = local.resource_group_name
  app_service_name    = local.app_service_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  docker_image_name   = local.docker_image_name
  aad_client_id       = local.staging_aad_client_id
  app_settings        = merge(local.app_settings, { DATABASE_URL = local.staging_database_url })
}
