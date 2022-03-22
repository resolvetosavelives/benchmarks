terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 0.2.0"
    }
  }
}

locals {
}

# The project is created manually by WHO.
data "azuredevops_project" "p" {
  name = var.devops_project_name
}

# resource "azuredevops_environment" "staging" {
#   project_id = data.azuredevops_project.p.id
#   name       = "Staging"
# }

# resource "azuredevops_environment" "production" {
#   project_id = data.azuredevops_project.p.id
#   name       = "Production"
# }

resource "azuredevops_variable_group" "vars" {
  project_id   = data.azuredevops_project.p.id
  name         = "pipeline-variables"
  description  = "Managed by DevOps Bootstrap Terraform - Variables needed for the pipeline to work and to apply the rest of the terraform config"
  allow_access = true

  variable {
    name         = "RAILS_MASTER_KEY"
    secret_value = var.RAILS_MASTER_KEY
    is_secret    = true
  }
  variable {
    name  = "TERRAFORM_RESOURCE_GROUP_NAME"
    value = var.terraform_resource_group_name
  }
  variable {
    name  = "TERRAFORM_STORAGE_ACCOUNT_NAME"
    value = var.terraform_storage_account_name
  }
  variable {
    name  = "TERRAFORM_CONTAINER_NAME"
    value = var.terraform_container_name
  }
  variable {
    name  = "ORGANIZATION_PREFIX"
    value = var.organization_prefix
  }
  # - AZURE_RESOURCE_GROUP_NAME
  # From the run itself:
  # - AZURE_APP_SERVICE_NAME
  # - PRODUCTION_DATABASE_URL
  # variable {
  #   name  = "CONTAINER_REGISTRY_DOMAIN"
  #   value = var.container_registry_domain
  # }
  # variable {
  #   name  = "CONTAINER_REPOSITORY"
  #   value = var.container_repository
  # }
  # variable {
  #   name  = "ACR_SERVICE_ENDPOINT_NAME"
  #   value = azuredevops_serviceendpoint_dockerregistry.acr.service_endpoint_name
  # }
}

resource "azuredevops_build_definition" "build" {
  project_id = data.azuredevops_project.p.id
  name       = "IHRBenchmark"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = var.github_repo_id
    branch_name           = var.github_branch
    service_connection_id = var.github_service_connection_id
    yml_path              = var.azure_pipelines_yml_path
  }

  variable_groups = [
    azuredevops_variable_group.vars.id
  ]
}

# This would be the correct way to make the ACR service connection.
# However, we currently have insufficient privileges.
# If this is fixed, this way is preferred over the above resource.
# data "azurerm_subscription" "current" {}
# resource "azuredevops_serviceendpoint_azurecr" "azurecr" {
#   project_id                = data.azuredevops_project.p.id
#   service_endpoint_name     = "SC-IHRBENCHMARK-P-AZURECR"
#   resource_group            = var.resource_group_name
#   azurecr_name              = var.azure_container_registry_name # "whoihrbenchmark"
#   azurerm_spn_tenantid      = data.azurerm_subscription.current.tenant_id
#   azurerm_subscription_id   = data.azurerm_subscription.current.subscription_id
#   azurerm_subscription_name = data.azurerm_subscription.current.display_name
# }
