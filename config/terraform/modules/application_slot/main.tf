data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_app_service_slot" "slot" {
  name                = "staging"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  app_service_plan_id = var.app_service_plan_id
  app_service_name    = var.app_service_name
  app_settings        = var.app_settings

  identity {
    type = "SystemAssigned"
  }
  site_config {
    always_on              = true
    vnet_route_all_enabled = true
    linux_fx_version       = "DOCKER|${var.docker_image_name}"
    ftps_state             = "Disabled"
    health_check_path      = "/healthcheck"
  }
  auth_settings {
    enabled                       = true
    runtime_version               = "~1"
    additional_login_params       = { scope = "openid email" }
    unauthenticated_client_action = "AllowAnonymous"
    active_directory {
      client_id = var.aad_client_id
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

resource "azurerm_app_service_slot_custom_hostname_binding" "hostname_binding" {
  app_service_slot_id = azurerm_app_service_slot.slot.id
  hostname            = var.hostname
}
