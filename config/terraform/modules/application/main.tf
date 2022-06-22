
locals {
  docker_image_name = "${azurerm_container_registry.acr.login_server}/${var.container_repository}:latest"
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
  auth_issuer = "https://sts.windows.net/${data.azurerm_subscription.current.tenant_id}/v2.0"
  # This is the microsoft provider issuer.
  # At one point it seemed like this was required, along with a `microsoft {`
  # block instead of `active_directory {` in order to login with any microsoft
  # account, but now it seems not wo work anymore. Not clear why or if it
  # will be necessary again. You might also need to remove the `allowed_audiencies`.
  # auth_issuer = "https://login.microsoftonline.com/common/v2.0"
}

data "azurerm_subscription" "current" {
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
  sku                           = "Standard"
  public_network_access_enabled = true
  admin_enabled                 = true
}

# An interesting thing about Azure is that all app services (and slots) run on
# all the instances allocated in the app service plan. Adding more slots does
# not cost more money, it just shares the resources across all the slots.
#
# See documentation here for price and capabilities of each tier:
# https://azure.microsoft.com/en-us/pricing/details/app-service/linux/
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.app_service_name}-app-service-plan"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  // must be kind="Linux" and reserved=true in order to run Linux containers
  kind     = "Linux"
  reserved = true
  sku {
    tier = "Standard"
    size = "S1" # S2 would get more memory. Upgrade if we have issues.
  }
}

resource "azurerm_app_service" "app_service" {
  # This name becomes a subdomain in a globally accessible URL, so must be globally unique
  name                = var.app_service_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_settings        = merge(local.app_settings, { DATABASE_URL = var.production_database_url })
  site_config {
    always_on              = true
    vnet_route_all_enabled = true
    linux_fx_version       = "DOCKER|${local.docker_image_name}"
    ftps_state             = "Disabled"
    health_check_path      = "/healthcheck"
  }
  auth_settings {
    enabled                       = true
    token_store_enabled           = true # must be enabled to receive access token in the headers
    unauthenticated_client_action = "AllowAnonymous"
    runtime_version               = "~1"
    issuer                        = local.auth_issuer
    active_directory {
      allowed_audiences = ["api://${var.azure_auth_application_id_production}"]
      client_id         = var.azure_auth_application_id_production
      client_secret     = var.azure_auth_client_secret_production
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
    application_logs { file_system_level = "Verbose" }
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes because deploys change which tag is deployed
      site_config["linux_fx_version"],
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"],
      # Ignore because auth settings are managed manually and terraform tries to nullify them.
      app_settings["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"],
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

  site_config {
    always_on              = false
    vnet_route_all_enabled = true
    linux_fx_version       = "DOCKER|${local.docker_image_name}"
    ftps_state             = "Disabled"
    health_check_path      = "/healthcheck"
  }
  auth_settings {
    enabled                       = true
    token_store_enabled           = true # must be enabled to receive access token in the headers
    unauthenticated_client_action = "AllowAnonymous"
    runtime_version               = "~1"
    issuer                        = local.auth_issuer
    active_directory {
      allowed_audiences = ["api://${var.azure_auth_application_id_preview}"]
      client_id         = var.azure_auth_application_id_preview
      client_secret     = var.azure_auth_client_secret_preview
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
      app_settings["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"],
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

  site_config {
    always_on              = true
    vnet_route_all_enabled = true
    linux_fx_version       = "DOCKER|${local.docker_image_name}"
    ftps_state             = "Disabled"
    health_check_path      = "/healthcheck"
  }
  auth_settings {
    enabled                       = true
    token_store_enabled           = true # must be enabled to receive access token in the headers
    unauthenticated_client_action = "AllowAnonymous"
    runtime_version               = "~1"
    issuer                        = local.auth_issuer
    active_directory {
      allowed_audiences = ["api://${var.azure_auth_application_id_staging}"]
      client_id         = var.azure_auth_application_id_staging
      client_secret     = var.azure_auth_client_secret_staging
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
      app_settings["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"],
    ]
  }
}
