locals {
  docker_image_name = "${var.container_registry_domain}/${var.container_repository}:latest"
  app_settings = merge(var.app_settings, {
    DOCKER_REGISTRY_SERVER_URL          = "https://${var.container_registry_domain}"
    DOCKER_CUSTOM_IMAGE_NAME            = local.docker_image_name
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    WEBSITE_ENABLE_SYNC_UPDATE_SITE     = true
    WEBSITE_HEALTHCHECK_MAXPINGFAILURES = 10
    # These vars are used in multiple places in this module, hence they are passed in as vars. When possible, set vars higher up the hierarchy
    AZURE_APPLICATION_CLIENT_SECRET = var.azure_auth_client_secret
    AZURE_APPLICATION_CLIENT_ID     = var.azure_auth_application_id
    APPLICATION_HOST                = var.domain_name
    SENDGRID_DOMAIN                 = var.domain_name
    SENDGRID_USERNAME               = "apikey"
    SENDGRID_API_KEY                = var.sendgrid_api_key
  })
  auth_issuer = "https://sts.windows.net/${var.tenant_id}/v2.0"
  # This is the microsoft provider issuer.
  # At one point it seemed like this was required, along with a `microsoft {`
  # block instead of `active_directory {` in order to login with any microsoft
  # account, but now it seems not wo work anymore. Not clear why or if it
  # will be necessary again. You might also need to remove the `allowed_audiencies`.
  # auth_issuer = "https://login.microsoftonline.com/common/v2.0"
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# An interesting thing about Azure is that all app services (and slots) run on
# all the instances allocated in the app service plan. Adding more slots does
# not cost more money, it just shares the resources across all the slots.
#
# See documentation here for price and capabilities of each tier:
# https://azure.microsoft.com/en-us/pricing/details/app-service/linux/
resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.app_service_name}-app-service-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "app_service" {
  # This name becomes a subdomain in a globally accessible URL, so must be globally unique
  name                      = var.app_service_name
  resource_group_name       = data.azurerm_resource_group.rg.name
  location                  = data.azurerm_resource_group.rg.location
  service_plan_id           = azurerm_service_plan.app_service_plan.id
  virtual_network_subnet_id = var.app_outbound_subnet_id

  app_settings = local.app_settings

  site_config {
    always_on              = true
    vnet_route_all_enabled = true
    ftps_state             = "Disabled"
    health_check_path      = "/healthcheck"
    use_32_bit_worker      = false
  }

  auth_settings {
    enabled                       = true
    token_store_enabled           = true # must be enabled to receive access token in the headers
    unauthenticated_client_action = "AllowAnonymous"
    runtime_version               = "~1"
    issuer                        = local.auth_issuer
    active_directory {
      allowed_audiences = ["api://${var.azure_auth_application_id}"]
      client_id         = var.azure_auth_application_id
      client_secret     = var.azure_auth_client_secret
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
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"],
      # Ignore because auth settings are managed manually and terraform tries to nullify them.
      app_settings["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"],
    ]
  }
}
resource "azurerm_linux_web_app_slot" "preview" {
  name           = "preview"
  app_service_id = azurerm_linux_web_app.app_service.id
  app_settings = merge(local.app_settings, {
    WEBSITE_PULL_IMAGE_OVER_VNET = true,
    WEBSITE_CONTENTOVERVNET      = 1
  })

  site_config {
    always_on              = false
    vnet_route_all_enabled = true
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
      allowed_audiences = ["api://${var.azure_auth_application_id}"]
      client_id         = var.azure_auth_application_id
      client_secret     = var.azure_auth_client_secret
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
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"],
      app_settings["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"],
    ]
  }
}
moved {
  from = azurerm_app_service_slot_virtual_network_swift_connection.example
  to   = azurerm_app_service_slot_virtual_network_swift_connection.preview-integration
}

/**
In order for this integration to full work, and for the preview app to start up, the preview app must also use the vnet for configuration.
You need to do that manually. (Theoretically, there are app settings vars that do it, but they don't seem to work.

Each of these commands should be run for both UAT and prod

az resource update --resource-group <ResourceGroup>--ids <PreviewSlotID> --resource-type "Microsoft.Web/sites/slots" --set properties.vnetImagePullEnabled=true

az resource update  --resource-group <ResourceGroup>--ids <PreviewSlotID> --resource-type "Microsoft.Web/sites/slots" --set properties.vnetContentShareEnabled=true
**/
resource "azurerm_app_service_slot_virtual_network_swift_connection" "preview-integration" {
  slot_name      = azurerm_linux_web_app_slot.preview.name
  app_service_id = azurerm_linux_web_app.app_service.id
  subnet_id      = var.app_outbound_subnet_id
}
