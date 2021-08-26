
resource "azuredevops_project" "project" {
  name = "WhoIhrBenchmarks001"
  description = "WHO IHR Benchmarks Project"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}

resource "azuredevops_git_repository" "repository" {
  project_id = azuredevops_project.project.id
  name       = "WHO IHR Benchmarks"
  initialization {
    init_type   = "Import"
    source_type = "Git"
    source_url  = "https://github.com/resolvetosavelives/benchmarks.git"
  }
}

resource "azuredevops_serviceendpoint_github" "serviceendpoint_gh_1" {
  project_id = azuredevops_project.project.id
  service_endpoint_name = "Benchmarks GitHub repo"
  # this is a real Personal access tokens to Github that expires in 90 days
  auth_personal {
    personal_access_token = var.GITHUB_AUTH_PERSONAL
  }
}

// build_definition this is what devops.azure.com calls a pipeline
resource "azuredevops_build_definition" "build_definition" {
  project_id = azuredevops_project.project.id
  name       = "Pipeline for Staging Build, Test, and Deploy 001"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "GitHub"
    repo_id     = "resolvetosavelives/benchmarks"
    branch_name = "pipeline-create-and-setup--178993699--build"
    yml_path    = "azure-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.serviceendpoint_gh_1.id
  }

  variable {
    name = "DATABASE_URL"
    is_secret = true
    secret_value = var.DATABASE_URL
    allow_override = false
  }
}
