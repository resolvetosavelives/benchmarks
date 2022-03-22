terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.93"
    }
  }

  backend "azurerm" {
    // Variables not allowed in this block
    container_name       = "tfstate"
    resource_group_name  = "IHRBENCHMARK-MAIN-WEU-RG01"
    storage_account_name = "tfstate9e02dada"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

module "main" {
  source                   = "../../main.tf"
  organization_prefix      = "who"
  RAILS_MASTER_KEY         = var.RAILS_MASTER_KEY
  prod_resource_group_name = "IHRBENCHMARK-P-WEU-RG01"
  test_resource_group_name = "IHRBENCHMARK-T-WEU-RG01"
  devops_project_name      = "IHRBENCHMARK"
}

moved {
  from = module.database
  to   = module.main.module.database
}
moved {
  from = module.devops
  to   = module.main.module.devops
}
moved {
  from = azurerm_app_service_plan.app_service_plan
  to   = module.main.module.application.azurerm_app_service_plan.app_service_plan
}
moved {
  from = azurerm_app_service.app_service
  to   = module.main.module.application.azurerm_app_service.app_service
}
moved {
  from = azurerm_app_service_slot.preview
  to   = module.main.module.application.azurerm_app_service_slot.preview
}
moved {
  from = azurerm_app_service_slot.staging
  to   = module.main.module.application.azurerm_app_service_slot.staging
}

moved {
  from = azurerm_container_registry.acr
  to   = module.main.module.application.azurerm_container_registry.acr
}
