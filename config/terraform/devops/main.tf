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
  name         = "pipeline-variable-group"
  description  = "Managed by Terraform - Variables needed for the pipeline to work"
  allow_access = true

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
