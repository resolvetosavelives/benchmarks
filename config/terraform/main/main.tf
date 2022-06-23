terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.93"
    }
  }
}

locals {
  app_name             = "ihrbenchmark"
  container_repository = "benchmarks"
  # Avoiding the word "production" in scope helps alleviate the confusion of "whoproduction-ihrbenchmark-staging"
  scope = join("", [
    var.organization,
    terraform.workspace == "production" ? "" : terraform.workspace,
  ])
  scoped_app_name = "${local.scope}-${local.app_name}"
}

data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "prod" {
  name = var.prod_resource_group_name
}


# with the Basic sku we get less bandwidth, modest performance and storage, and no privacy (could be accessed by public internet if the URL is discovered)
# more info on sku Service tier features and limits: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus
resource "azurerm_container_registry" "acr" {
  # This becomes a <name>.azurecr.io, so it must following the rules:
  # lower case alpha numeric characters. Globally unique.
  name                = replace(lower(local.scoped_app_name), "/[^a-z0-9]/", "") # e.g. whoihrbenchmark
  resource_group_name = data.azurerm_resource_group.prod.name
  location            = data.azurerm_resource_group.prod.location
  sku                 = "Standard"
  # This could potentially be false if we could get the service connection working through azure devops
  public_network_access_enabled = true
  admin_enabled                 = true
}

module "database_uat" {
  source              = "../modules/database"
  resource_group_name = var.test_resource_group_name
  namespace           = "${local.scoped_app_name}-uat"
  database_name       = "benchmarks_uat"
}

module "database" {
  source              = "../modules/database"
  resource_group_name = var.prod_resource_group_name
  namespace           = local.scoped_app_name
  database_name       = "benchmarks_production"
}

module "application_uat" {
  source                            = "../modules/application"
  resource_group_name               = var.test_resource_group_name
  app_service_name                  = "${local.scoped_app_name}-uat"
  database_url                      = module.database_uat.database_url
  container_registry_domain         = azurerm_container_registry.acr.login_server
  container_registry_username       = azurerm_container_registry.acr.admin_username
  container_registry_password       = azurerm_container_registry.acr.admin_password
  container_repository              = local.container_repository
  RAILS_MASTER_KEY                  = var.RAILS_MASTER_KEY
  azure_auth_application_id_preview = var.azure_auth_application_id_preview
  azure_auth_application_id         = var.azure_auth_application_id_staging
  azure_auth_client_secret_preview  = var.azure_auth_client_secret_preview
  azure_auth_client_secret          = var.azure_auth_client_secret_staging
}

module "application" {
  source                            = "../modules/application"
  resource_group_name               = var.prod_resource_group_name
  app_service_name                  = local.scoped_app_name
  database_url                      = module.database.database_url
  container_registry_domain         = azurerm_container_registry.acr.login_server
  container_registry_username       = azurerm_container_registry.acr.admin_username
  container_registry_password       = azurerm_container_registry.acr.admin_password
  container_repository              = local.container_repository
  RAILS_MASTER_KEY                  = var.RAILS_MASTER_KEY
  azure_auth_application_id_preview = var.azure_auth_application_id_preview
  azure_auth_application_id         = var.azure_auth_application_id_production
  azure_auth_client_secret_preview  = var.azure_auth_client_secret_preview
  azure_auth_client_secret          = var.azure_auth_client_secret_production
}

module "devops" {
  source                       = "../modules/devops"
  devops_project_name          = var.devops_project_name
  test_resource_group_name     = var.test_resource_group_name
  prod_resource_group_name     = var.prod_resource_group_name
  uat_app_service_name         = module.application_uat.app_service_name
  prod_app_service_name        = module.application.app_service_name
  container_registry_domain    = azurerm_container_registry.acr.login_server
  container_registry_username  = azurerm_container_registry.acr.admin_username
  container_registry_password  = azurerm_container_registry.acr.admin_password
  container_repository         = local.container_repository
  github_repo_id               = var.github_repo_id
  github_branch                = var.github_branch
  github_service_connection_id = var.github_service_connection_id
  azure_pipelines_yml_path     = var.azure_pipelines_yml_path
}
