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
  # These resource groups are created manually by WHO.
  # If deployed to a non-WHO Azure environment, these must be created manually.
  resource_group_name = terraform.workspace == "production" ? var.prod_resource_group_name : var.test_resource_group_name
  # Avoiding the word "production" in scope helps alleviate the confusion of "whoproduction-ihrbenchmark-staging"
  scope = join("", [
    var.organization,
    terraform.workspace == "production" ? "" : terraform.workspace,
  ])
  scoped_app_name = "${local.scope}-${local.app_name}"
}

data "azurerm_subscription" "current" {}

module "aad_staging_application" {
  source    = "../modules/aad_application"
  tenant_id = data.azurerm_subscription.current.tenant_id
  name      = "${upper(local.app_name)} (staging)"
  domain    = "${local.scoped_app_name}-staging.azurewebsites.net"
  # The domain is a chicken-and-egg problem.
  # The app service will assign the domain. Luckily it's deterministic.
  # A custom domain would be more declarative.
}

module "aad_preview_application" {
  source    = "../modules/aad_application"
  tenant_id = data.azurerm_subscription.current.tenant_id
  name      = "${upper(local.app_name)} (preview)"
  domain    = "${local.scoped_app_name}-preview.azurewebsites.net"
}

module "aad_production_application" {
  source    = "../modules/aad_application"
  tenant_id = data.azurerm_subscription.current.tenant_id
  name      = upper(local.app_name)
  domain    = "${local.scoped_app_name}.azurewebsites.net"
}

module "database" {
  source              = "../modules/database"
  resource_group_name = local.resource_group_name
  namespace           = local.scoped_app_name
}

module "application" {
  source                        = "../modules/application"
  resource_group_name           = local.resource_group_name
  app_service_name              = local.scoped_app_name
  staging_aad_application_id    = module.aad_staging_application.application_id
  preview_aad_application_id    = module.aad_preview_application.application_id
  production_aad_application_id = module.aad_production_application.application_id
  staging_database_url          = module.database.staging_database_url
  production_database_url       = module.database.production_database_url
  container_repository          = local.container_repository
  RAILS_MASTER_KEY              = var.RAILS_MASTER_KEY
}

module "devops" {
  source                      = "../modules/devops"
  project_name                = var.devops_project_name
  resource_group_name         = local.resource_group_name
  app_service_name            = module.application.app_service_name
  container_registry_domain   = module.application.acr_login_server
  container_registry_username = module.application.acr_admin_username
  container_registry_password = module.application.acr_admin_password
  container_repository        = local.container_repository
}
