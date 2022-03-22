terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 0.2.0"
    }
  }
}

locals {
  # Although this name is similar to a manual WHO admin created service endpoint, we do create this here.
  acr_service_endpoint_name = "SC-IHRBENCHMARK-P-ACR-CREDENTIAL"
}

# The project is created manually by WHO.
data "azuredevops_project" "p" {
  name = var.devops_project_name
}

resource "azuredevops_serviceendpoint_dockerregistry" "acr" {
  project_id            = data.azuredevops_project.p.id
  service_endpoint_name = local.acr_service_endpoint_name
  docker_registry       = "https://${var.container_registry_domain}"
  docker_username       = var.container_registry_username
  docker_password       = var.container_registry_password
  registry_type         = "Others"
}

resource "azuredevops_environment" "staging" {
  project_id = data.azuredevops_project.p.id
  name       = "Staging"
}

resource "azuredevops_environment" "production" {
  project_id = data.azuredevops_project.p.id
  name       = "Production"
}

resource "azuredevops_variable_group" "vars" {
  project_id   = data.azuredevops_project.p.id
  name         = "pipeline-variable-group"
  description  = "Managed by Terraform - Variables sourced from terraform configuration that are needed for the pipeline to work"
  allow_access = true

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
    value = azuredevops_serviceendpoint_dockerregistry.acr.service_endpoint_name
  }
}

# This would be the correct way to make the ACR service connection.
# However, we currently have insufficient privileges.
# If this is fixed, this way is preferred over the above resource.
# data "azurerm_subscription" "current" {}
# resource "azuredevops_serviceendpoint_azurecr" "azurecr" {
#   project_id                = data.azuredevops_project.project.id
#   service_endpoint_name     = "SC-IHRBENCHMARK-P-AZURECR"
#   resource_group            = var.resource_group_name
#   azurecr_name              = "whoihrbenchmark"
#   azurerm_spn_tenantid      = data.azurerm_subscription.current.tenant_id
#   azurerm_subscription_id   = data.azurerm_subscription.current.subscription_id
#   azurerm_subscription_name = data.azurerm_subscription.current.display_name
# }
