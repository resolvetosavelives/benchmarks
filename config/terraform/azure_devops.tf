#
# SECTION: Variables used
#
variable "GITHUB_AUTH_PERSONAL" {
  type      = string
  sensitive = true
}

resource "azuredevops_project" "project" {
  name               = "IHRBENCHMARK"
  description        = "DevOps Project for WHO IHR Benchmarks"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Basic"
}

resource "azuredevops_serviceendpoint_github" "serviceendpoint_for_who_github" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "WorldHealthOrganization"
  description           = "Created by Andre for GitHub repo WorldHealthOrganization/ihrbenchmark"
  # this is a real Personal access token to Github that expires in 90 days
  auth_personal {
    personal_access_token = var.GITHUB_AUTH_PERSONAL
  }
}

// build_definition this is what devops.azure.com calls a pipeline
resource "azuredevops_build_definition" "build_definition" {
  project_id = azuredevops_project.project.id
  name       = "Build Pipeline for WHO IHR Benchmarks"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "WorldHealthOrganization/ihrbenchmark"
    branch_name           = "main-azure"
    yml_path              = "azure-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.serviceendpoint_for_who_github.id
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

#  TODO: not working yet, fails with:
#│ Error:  waiting for service endpoint ready. Error looking up service endpoint given ID (50ca50d8-27c1-4974-894e-4de45523eb51) and project ID (679f7d50-14c7-4b17-aea0-cc0e0452141b): map[state:Failed statusMessage:Failed to create an app in Azure Active Directory. Error: Insufficient privileges to complete the operation. Ensure that the user has permissions to create an Azure Active Directory Application.]
#│
#│   with azuredevops_serviceendpoint_azurecr.serviceendpoint_acr,
#│   on azure_devops.tf line 58, in resource "azuredevops_serviceendpoint_azurecr" "serviceendpoint_acr":
#│   58: resource "azuredevops_serviceendpoint_azurecr" "serviceendpoint_acr" {
#
#resource "azuredevops_serviceendpoint_azurecr" "serviceendpoint_acr" {
#  project_id                = azuredevops_project.project.id
#  service_endpoint_name     = "Service Endpoint for WHO IHR Benchmarks Azure Container Registry"
#  resource_group            = local.rg_for_workspace
#  azurecr_spn_tenantid      = data.azurerm_subscription.current.tenant_id
#  azurecr_name              = azurerm_container_registry.acr.name
#  azurecr_subscription_id   = data.azurerm_subscription.current.subscription_id
#  azurecr_subscription_name = local.subscription_name
#}
