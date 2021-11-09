#
# SECTION: Variables used
#
variable "GITHUB_AUTH_PERSONAL" {
  type      = string
  sensitive = true
}

resource "azuredevops_project" "project" {
  name               = "WhoIhrBenchmarks001"
  description        = "DevOps Project for WHO IHR Benchmarks"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}

resource "azuredevops_git_repository" "repository" {
  project_id = azuredevops_project.project.id
  name       = "Github Repo for WHO IHR Benchmarks"
  initialization {
    init_type   = "Import"
    source_type = "Git"
    source_url  = "https://github.com/resolvetosavelives/benchmarks.git"
  }
}

resource "azuredevops_serviceendpoint_github" "serviceendpoint_gh_1" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "Service Endpoint for GitHub repo for WHO IHR Benchmarks"
  # this is a real Personal access tokens to Github that expires in 90 days
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
    repo_id               = "resolvetosavelives/benchmarks"
    branch_name           = "automate-docker-image-builds-with-acr-from-the-pipeline--179500509"
    yml_path              = "azure-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.serviceendpoint_gh_1.id
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

resource "azuredevops_serviceendpoint_azurecr" "serviceendpoint_acr" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "Service Endpoint for WHO IHR Benchmarks Azure Container Registry"
  resource_group = azurerm_resource_group.who_ihr_benchmarks.name
  azurecr_spn_tenantid = data.azurerm_subscription.current.tenant_id
  azurecr_name = azurerm_container_registry.acr.name
  azurecr_subscription_id = data.azurerm_subscription.current.subscription_id
  azurecr_subscription_name = local.subscription_name
}
