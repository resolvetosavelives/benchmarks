terraform {
  required_version = "~> 1.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.24.0"
    }
  }
}

data "azurerm_client_config" "current" {}

locals {
  app_name             = "ihrbenchmark"
  container_repository = "benchmarks"
  scope                = join("", [var.organization])
  scoped_app_name      = "${local.scope}-${local.app_name}"
  scoped_app_name_uat  = "${local.scoped_app_name}-uat"
  tenant_id            = data.azurerm_client_config.current.tenant_id
  object_id            = data.azurerm_client_config.current.object_id
}

module "container_registry" {
  source              = "../modules/container_registry"
  resource_group_name = var.prod_resource_group_name
  location            = var.location
  app_name            = local.scoped_app_name
  github_pat          = var.github_pat
  repo_name           = local.container_repository
}

module "network_uat" {
  source                    = "../modules/network"
  resource_group_name       = var.test_resource_group_name
  location                  = var.location
  namespace                 = local.scoped_app_name_uat
  domain_name               = var.uat_domain_name
  key_vault_developer_ips   = var.developer_ips
  key_vault_developer_group = var.developer_group
  tenant_id                 = local.tenant_id
  object_id                 = local.object_id
  tags                      = var.uat_tags
  debug_mode                = var.uat_debug_mode
}

module "network" {
  source                    = "../modules/network"
  resource_group_name       = var.prod_resource_group_name
  location                  = var.location
  namespace                 = local.scoped_app_name
  domain_name               = var.domain_name
  key_vault_developer_ips   = var.developer_ips
  key_vault_developer_group = var.developer_group
  tenant_id                 = local.tenant_id
  object_id                 = local.object_id
  tags                      = var.prod_tags
}

module "tls" {
  source                    = "../modules/tls"
  prod_resource_group_name  = var.prod_resource_group_name
  test_resource_group_name  = var.test_resource_group_name
  location                  = var.location
  namespace                 = local.scoped_app_name
  domain_name               = var.domain_name
  key_vault_developer_ips   = var.developer_ips
  key_vault_developer_group = var.developer_group
  tenant_id                 = local.tenant_id
  object_id                 = local.object_id
  tags                      = var.prod_tags
  subject_alt_names = [
    var.domain_name,
    module.network.gateway_ip_addr,
    module.network_uat.gateway_ip_addr
  ]
  subnet_id        = module.network.service_subnet_id
  cert_name        = var.cert_name
  create_key_vault = var.create_key_vault
  key_vault_name   = var.key_vault_name
}

module "application_gateway_uat" {
  source              = "../modules/application_gateway"
  cert_name           = var.cert_name
  key_vault_name      = var.key_vault_name
  location            = var.location
  resource_group_name = var.test_resource_group_name
  managed_identity_id = module.tls.prod_managed_identity_id
  namespace           = local.scoped_app_name_uat
  public_ip_id        = module.network_uat.gateway_ip_id
  subnet_id           = module.network_uat.service_subnet_id
  tags                = var.uat_tags
  domain_name         = var.uat_domain_name
}

module "application_gateway" {
  source              = "../modules/application_gateway"
  cert_name           = var.cert_name
  key_vault_name      = var.key_vault_name
  location            = var.location
  resource_group_name = var.prod_resource_group_name
  managed_identity_id = module.tls.prod_managed_identity_id
  namespace           = local.scoped_app_name
  public_ip_id        = module.network.gateway_ip_id
  subnet_id           = module.network.service_subnet_id
  tags                = var.uat_tags
  domain_name         = var.domain_name
}

module "database_uat" {
  source              = "../modules/database"
  resource_group_name = var.test_resource_group_name
  location            = var.location
  namespace           = local.scoped_app_name_uat
  fqdn                = "${local.scoped_app_name_uat}-postgresql.privatelink.postgres.database.azure.com"
  database_name       = "benchmarks_uat"
  developer_ips       = var.developer_ips
}

module "database" {
  source              = "../modules/database"
  resource_group_name = var.prod_resource_group_name
  location            = var.location
  namespace           = local.scoped_app_name
  fqdn                = "${local.scoped_app_name}-postgresql.privatelink.postgres.database.azure.com"
  database_name       = "benchmarks_production"
  developer_ips       = var.developer_ips
}

module "ci_agent_uat" {
  source              = "../modules/ci_agent"
  resource_group_name = var.test_resource_group_name
  location            = var.location
  vnet_name           = module.network_uat.vnet_name
  subnet_id           = module.network_uat.ci_agent_subnet_id
  namespace           = local.scoped_app_name_uat
  ci_agent_public_key = var.ci_agent_public_key
}

module "ci_agent" {
  source              = "../modules/ci_agent"
  resource_group_name = var.prod_resource_group_name
  location            = var.location
  vnet_name           = module.network.vnet_name
  subnet_id           = module.network.ci_agent_subnet_id
  namespace           = local.scoped_app_name
  ci_agent_public_key = var.ci_agent_public_key
}

module "application_uat" {
  source                    = "../modules/application"
  resource_group_name       = var.test_resource_group_name
  location                  = var.location
  app_service_name          = local.scoped_app_name_uat
  container_registry_domain = module.container_registry.acr_domain
  container_repository      = local.container_repository
  azure_auth_application_id = var.azure_auth_application_id_staging
  azure_auth_client_secret  = var.azure_auth_client_secret_staging
  app_settings = merge(var.app_settings, {
    ADMIN_EMAIL                     = var.admin_email_uat
    DOCKER_REGISTRY_SERVER_USERNAME = module.container_registry.acr_admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = module.container_registry.acr_admin_password
    DATABASE_URL                    = module.database_uat.database_url
    AVO_LICENSE_KEY                 = var.avo_license_key_uat
  })
  tenant_id              = local.tenant_id
  sendgrid_api_key       = var.sendgrid_api_key
  domain_name            = var.uat_domain_name
  app_outbound_subnet_id = module.network_uat.app_outbound_subnet_id
}

module "application" {
  source                    = "../modules/application"
  resource_group_name       = var.prod_resource_group_name
  location                  = var.location
  app_service_name          = local.scoped_app_name
  container_registry_domain = module.container_registry.acr_domain
  container_repository      = local.container_repository
  azure_auth_application_id = var.azure_auth_application_id_production
  azure_auth_client_secret  = var.azure_auth_client_secret_production
  app_settings = merge(var.app_settings, {
    ADMIN_EMAIL                     = var.admin_email_prod
    DOCKER_REGISTRY_SERVER_USERNAME = module.container_registry.acr_admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = module.container_registry.acr_admin_password
    DATABASE_URL                    = module.database.database_url
    AVO_LICENSE_KEY                 = var.avo_license_key
  })
  tenant_id              = local.tenant_id
  sendgrid_api_key       = var.sendgrid_api_key
  domain_name            = var.domain_name
  app_outbound_subnet_id = module.network.app_outbound_subnet_id
}

module "routing_uat" {
  source              = "../modules/routing"
  app_id              = module.application_uat.app_id
  db_id               = module.database_uat.database_id
  db_fqdn             = module.database_uat.database_fqdn
  location            = var.location
  resource_group_name = var.test_resource_group_name
  namespace           = local.scoped_app_name_uat
  subnet_id           = module.network_uat.private_endpoint_subnet_id
  # NOTE: we could get the subnet prefixes via a data element in the routing module based on the ID instead, but that causes a performance hit for every terraform plan or apply
  subnet_prefixes   = module.network_uat.private_endpoint_subnet_prefixes
  vnet_id           = module.network_uat.vnet_id
  app_dns_zone_id   = module.network_uat.app_dns_zone_id
  app_dns_zone_name = module.network_uat.app_dns_zone_name
  db_dns_zone_id    = module.network_uat.db_dns_zone_id
  db_dns_zone_name  = module.network_uat.db_dns_zone_name
  acr_id            = module.container_registry.acr_id
}
module "routing" {
  source              = "../modules/routing"
  app_id              = module.application.app_id
  db_id               = module.database.database_id
  db_fqdn             = module.database.database_fqdn
  location            = var.location
  resource_group_name = var.prod_resource_group_name
  namespace           = local.scoped_app_name
  subnet_id           = module.network.private_endpoint_subnet_id
  # NOTE: we could get the subnet prefixes via a data element in the routing module based on the ID instead, but that causes a performance hit for every terraform plan or apply
  subnet_prefixes   = module.network.private_endpoint_subnet_prefixes
  vnet_id           = module.network.vnet_id
  app_dns_zone_id   = module.network.app_dns_zone_id
  app_dns_zone_name = module.network.app_dns_zone_name
  db_dns_zone_id    = module.network.db_dns_zone_id
  db_dns_zone_name  = module.network.db_dns_zone_name
  acr_id            = module.container_registry.acr_id
}

module "devops" {
  source                       = "../modules/devops"
  devops_project_id            = var.devops_project_id
  test_resource_group_name     = var.test_resource_group_name
  prod_resource_group_name     = var.prod_resource_group_name
  uat_app_service_name         = module.application_uat.app_service_name
  prod_app_service_name        = module.application.app_service_name
  container_registry_name      = module.container_registry.acr_name
  container_registry_domain    = module.container_registry.acr_domain
  container_registry_username  = module.container_registry.acr_admin_username
  container_registry_password  = module.container_registry.acr_admin_password
  container_repository         = local.container_repository
  github_repo_id               = var.github_repo_id
  github_branch                = var.github_branch
  github_service_connection_id = var.github_service_connection_id
  azure_pipelines_yml_path     = var.azure_pipelines_yml_path
  github_pat_expiry            = var.github_pat_expiry
}
