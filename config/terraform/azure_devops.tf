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
    branch_name           = "pipeline-access-to-db-now-that-its-private--179445514"
    yml_path              = "azure-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.serviceendpoint_gh_1.id
  }

  variable {
    name           = "DATABASE_URL"
    is_secret      = true
    secret_value   = var.DATABASE_URL
    allow_override = false
  }
}
resource "azuredevops_serviceendpoint_azurerm" "project" {
  project_id                = azuredevops_project.project.id
  service_endpoint_name     = azurerm_private_endpoint.pend_db01.name
  description               = "DB conn for Build Pipeline"
  azurerm_spn_tenantid      = data.azurerm_subscription.current.tenant_id
  azurerm_subscription_id   = data.azurerm_subscription.current.subscription_id
  azurerm_subscription_name = data.azurerm_subscription.current.display_name
}
