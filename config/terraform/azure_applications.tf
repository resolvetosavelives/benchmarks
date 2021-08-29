//resource "azurerm_app_service_plan" "app_service_plan" {
//  name                = "who-ihr-benchmarks-app-service-plan"
//  location            = azurerm_resource_group.who_ihr_benchmarks.location
//  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
//  // these settings "kind" and "reserved" are required by Azure in order to use app_service's
//  //   config option linux_fx_version which we need to run Linux containers
//  kind                = "Linux"
//  reserved            = true
//  //  reserved            = true # do not need reserved for now
//  sku {
//    tier = "Standard"
//    size = "S1"
//  }
//}
//
//resource "azurerm_app_service" "app_service" {
//  name                = "who-ihr-benchmarks-app-service"
//  location            = azurerm_resource_group.who_ihr_benchmarks.location
//  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
//  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
//  //  health_check_path = "/health" # TODO
//  identity {
//    type = "SystemAssigned"
//  }
////  site_config {
////    linux_fx_version = "DOCKER|whoihrbenchmarksregistry.azurecr.io/benchmarks:latest"
////  }
////  // not sure if this goes to our app or to App Service layer
////  app_settings = {
////    DOCKER_REGISTRY_SERVER_URL = var.DOCKER_REGISTRY_SERVER_URL
////    DOCKER_REGISTRY_SERVER_USERNAME = var.DOCKER_REGISTRY_SERVER_USERNAME
////    DOCKER_REGISTRY_SERVER_PASSWORD = var.DOCKER_REGISTRY_SERVER_PASSWORD
////    DATABASE_URL = var.DATABASE_URL
////    RAILS_MASTER_KEY = var.RAILS_MASTER_KEY
////  }
////  logs {
////    // http_logs seems to be the Azure App Service-level logs, external to our app
////    http_logs {
////      file_system {
////        retention_in_days = 7
////        retention_in_mb = 100
////      }
////    }
////    // application_logs seems to mean logs from our actual app code in its container
////    application_logs {
////      file_system_level = "Verbose"
////    }
////  }
//}

//resource "azurerm_app_service_virtual_network_swift_connection" "network_peering_from_app_service" {
//  app_service_id = azurerm_app_service.app_service.id
//  subnet_id      = azurerm_subnet.app_service_integration.id
//}

//resource "azurerm_app_service_slot" "benchmarks_staging_slot" {
//  name                = "staging"
//  location            = azurerm_resource_group.who_ihr_benchmarks.location
//  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
//  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
//  app_service_name    = azurerm_app_service.app_service.name
//}
