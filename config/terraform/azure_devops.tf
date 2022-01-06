#
# SECTION: Variables used
#
variable "GITHUB_AUTH_PERSONAL" {
  type      = string
  sensitive = true
}

# resource "azuredevops_project" "project" {
#   name               = "IHRBENCHMARK"
#   description        = "DevOps Project for WHO IHR Benchmarks"
#   visibility         = "private"
#   version_control    = "Git"
#   work_item_template = "Basic"
# }

#
# resource "azuredevops_serviceendpoint_github" "serviceendpoint_for_github" {
#   project_id            = local.devops_project_id
#   service_endpoint_name = "resolvetosavelives/benchmarks"
#   description           = "For GitHub repo resolvetosavelives/benchmarks"
#   # this is a real Personal access token to Github that expires in 90 days
#   auth_personal {
#     personal_access_token = var.GITHUB_AUTH_PERSONAL
#   }
# }

// build_definition this is what devops.azure.com calls a pipeline
resource "azuredevops_build_definition" "build_definition" {
  project_id = local.devops_project_id
  name       = "Build Pipeline for WHO IHR Benchmarks"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_id               = var.GITHUB_REPO
    repo_type             = "GitHub"
    branch_name           = var.GITHUB_BRANCH
    yml_path              = "azure-pipelines.yml"
    service_connection_id = var.DEVOPS_GITHUB_SERVICE_CONNECTION_ID
  }

  variable {
    name           = "DATABASE_URL"
    is_secret      = true
    secret_value   = var.DATABASE_URL_FOR_PIPELINE
    allow_override = false
  }
  variable {
    name           = "RAILS_MASTER_KEY"
    is_secret      = true
    secret_value   = var.RAILS_MASTER_KEY
    allow_override = false
  }
}

# WHO creates this for us manually, so we can't manage it with Terraform
# resource "azuredevops_serviceendpoint_azurecr" "serviceendpoint_acr" {
#   project_id                = local.devops_project_id
#   service_endpoint_name     = "Service Endpoint for WHO IHR Benchmarks Azure Container Registry"
#   resource_group            = local.rg_for_workspace
#   azurecr_spn_tenantid      = data.azurerm_subscription.current.tenant_id
#   azurecr_name              = azurerm_container_registry.acr.name
#   azurecr_subscription_id   = data.azurerm_subscription.current.subscription_id
#   azurecr_subscription_name = local.subscription_name # removed, add back if we uncomment
# }
