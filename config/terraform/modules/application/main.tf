locals {
  docker_image_name     = "${azurerm_container_registry.acr.login_server}/${var.container_repository}:latest"
  tenant_id             = "4efe96cc-3e99-409d-8d0e-432bd2ad9fce"
  staging_aad_app_id    = "c34545e9-5dbe-49ec-a87b-57e3dcd7cc7d"
  production_aad_app_id = "1e49ba73-ea03-4cfa-a967-de8a1d63fb22"

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL          = "https://${azurerm_container_registry.acr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME     = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = azurerm_container_registry.acr.admin_password
    DOCKER_CUSTOM_IMAGE_NAME            = local.docker_image_name
    RAILS_MASTER_KEY                    = var.RAILS_MASTER_KEY
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    WEBSITE_ENABLE_SYNC_UPDATE_SITE     = true
    WEBSITE_HEALTHCHECK_MAXPINGFAILURES = 10
  }
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# with the Basic sku we get less bandwidth, modest performance and storage, and no privacy (could be accessed by public internet if the URL is discovered)
# more info on sku Service tier features and limits: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus
resource "azurerm_container_registry" "acr" {
  # This becomes a <name>.azurecr.io, so it must following the rules:
  # lower case alpha numeric characters. Globally unique.
  name                          = replace(lower(var.app_service_name), "/[^a-z0-9]/", "") # e.g. whoihrbenchmark
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  sku                           = "Premium"
  public_network_access_enabled = true
  admin_enabled                 = true
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.app_service_name}-app-service-plan"
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
  name                = var.app_service_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_settings        = merge(local.app_settings, { DATABASE_URL = var.production_database_url })
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
    token_store_enabled           = true
    additional_login_params       = { scope = "openid email" }
    unauthenticated_client_action = "AllowAnonymous"
    active_directory {
      client_id = local.production_aad_app_id
      allowed_audiences = [
        "api://${local.production_aad_app_id}",
      ]
      #client_secret = ""
    }
    issuer = "https://sts.windows.net/${local.tenant_id}/v2.0"
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
    application_logs { file_system_level = "Verbose" }
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes because deploys change which tag is deployed
      site_config["linux_fx_version"],
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"],
    ]
  }
}

resource "azurerm_app_service_slot" "preview" {
  name                = "preview"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_service_name    = azurerm_app_service.app_service.name
  app_settings        = merge(local.app_settings, { DATABASE_URL = var.production_database_url })

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
      client_id = local.production_aad_app_id
    }
  }
  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 100
      }
    }
    application_logs { file_system_level = "Verbose" }
  }
  lifecycle {
    ignore_changes = [
      site_config["linux_fx_version"],
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"],
    ]
  }
}

resource "azurerm_app_service_slot" "staging" {
  name                = "staging"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_service_name    = azurerm_app_service.app_service.name
  app_settings        = merge(local.app_settings, { DATABASE_URL = var.staging_database_url })

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
      client_id = local.staging_aad_app_id
    }
  }
  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 100
      }
    }
    application_logs { file_system_level = "Verbose" }
  }
  lifecycle {
    ignore_changes = [
      site_config["linux_fx_version"],
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"],
    ]
  }
}
