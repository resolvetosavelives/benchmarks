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
    name  = "CONTAINER_REGISTRY_DOMAIN"
    value = var.container_registry_domain
  }
  variable {
    name  = "CONTAINER_REPOSITORY"
    value = var.container_repository
  }
  variable {
    name  = "ACR_SERVICE_ENDPOINT_NAME"
    value = var.acr_service_endpoint_name
  }
}

resource "azuredevops_serviceendpoint_dockerregistry" "acr" {
  project_id            = data.azuredevops_project.project.id
  service_endpoint_name = var.acr_service_endpoint_name
  docker_registry       = "https://${var.container_registry_domain}"
  docker_username       = var.container_registry_username
  docker_password       = var.container_registry_password
  registry_type         = "Others"
}

# This would be the correct way to make the ACR service connection.
# However, we currently have insufficient privileges.
# If this is fixed, this way is preferred over the above resource.
# resource "azuredevops_serviceendpoint_azurecr" "azurecr" {
#   project_id                = data.azuredevops_project.project.id
#   service_endpoint_name     = "SC-IHRBENCHMARK-P-AZURECR"
#   resource_group            = var.resource_group_name
#   azurecr_spn_tenantid      = "f610c0b7-bd24-4b39-810b-3dc280afb590"
#   azurecr_name              = "whoihrbenchmark"
#   azurecr_subscription_id   = "974ebced-5bea-4fa8-af6f-7064aa3eccff"
#   azurecr_subscription_name = "IHRBENCHMARK IHR Benchmarks Capacity application hosting"
# }
