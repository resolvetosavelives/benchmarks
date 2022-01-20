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
  description  = "Managed by Terraform - Variables sourced from terraform configuration that are needed for the pipeline to work"
  allow_access = true

  variable {
    name         = "RAILS_MASTER_KEY"
    is_secret    = true
    secret_value = var.RAILS_MASTER_KEY
  }
  variable {
    name  = "AZURE_RESOURCE_GROUP_NAME"
    value = var.resource_group_name
  }
  variable {
    name  = "AZURE_APP_SERVICE_NAME"
    value = var.app_service_name
  }
  variable {
    name  = "AZURE_SUBSCRIPTION_SERVICE_CONNECTION"
    value = var.azure_subscription_service_connection
  }
  variable {
    name  = "CONTAINER_REGISTRY_DOMAIN"
    value = var.container_registry_domain
  }
  variable {
    name  = "CONTAINER_REPOSITORY"
    value = var.container_repository
  }
}
