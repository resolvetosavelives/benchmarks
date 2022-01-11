terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.1.7"
    }
  }
}

locals {
  # Created manually by WHO.
  project_name = "IHRBENCHMARK"
}

data "azuredevops_project" "project" {
  name = local.project_name
}

resource "azuredevops_variable_group" "vars" {
  project_id   = data.azuredevops_project.project.id
  name         = "Infrastructure Pipeline Variables"
  description  = "Managed by Terraform"
  allow_access = true

  variable {
    name         = "DATABASE_URL"
    is_secret    = true
    secret_value = var.DATABASE_URL
  }
  variable {
    name         = "RAILS_MASTER_KEY"
    is_secret    = true
    secret_value = var.RAILS_MASTER_KEY
  }
  variable {
    name         = "DEVOPS_DOCKER_ACR_SERVICE_CONNECTION_NAME"
    is_secret    = false
    secret_value = var.DEVOPS_DOCKER_ACR_SERVICE_CONNECTION_NAME
  }
}

// build_definition this is what devops.azure.com calls a pipeline
resource "azuredevops_build_definition" "build_definition" {
  project_id = data.azuredevops_project.project.id
  name       = "Build Pipeline for WHO IHR Benchmarks"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_id               = var.GITHUB_REPO
    repo_type             = "GitHub"
    branch_name           = var.GITHUB_BRANCH
    yml_path              = "azure-pipelines.yml"
    service_connection_id = var.GITHUB_SERVICE_CONNECTION_ID
  }

  variable_groups = [
    azuredevops_variable_group.vars.id
  ]
}
