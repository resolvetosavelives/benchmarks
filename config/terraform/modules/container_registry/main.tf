terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.24.0"
    }
  }
}


# with the Basic sku we get less bandwidth, modest performance and storage, and no privacy (could be accessed by public internet if the URL is discovered)
# more info on sku Service tier features and limits: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus
resource "azurerm_container_registry" "acr" {
  # This becomes a <name>.azurecr.io, so it must following the rules:
  # lower case alpha numeric characters. Globally unique.
  name                = replace(lower(var.app_name), "/[^a-z0-9]/", "") # e.g. whoihrbenchmark
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"
  # This could potentially be false if we could get the service connection working through azure devops
  public_network_access_enabled = true
  admin_enabled                 = true
}

resource "azurerm_container_registry_task" "build-base" {
  name                  = "build-base-image"
  container_registry_id = azurerm_container_registry.acr.id
  platform {
    os = "Linux"
  }
  docker_step {
    dockerfile_path      = "config/docker/builder/Dockerfile"
    context_path         = "https://github.com/WorldHealthOrganization/ihrbenchmark.git"
    context_access_token = var.github_pat
    image_names = [
      "${var.repo_name}:{{.Run.Commit}}",
      "${var.repo_name}_builder:latest"
    ]
    cache_enabled = false
  }
}

resource "azurerm_container_registry_task" "build" {
  name                  = "build-final-image"
  container_registry_id = azurerm_container_registry.acr.id
  platform {
    os = "Linux"
  }
  docker_step {
    dockerfile_path      = "config/docker/Dockerfile"
    context_path         = "https://github.com/WorldHealthOrganization/ihrbenchmark.git"
    context_access_token = var.github_pat
    image_names = [
      "${var.repo_name}:{{.Run.Commit}}",
      "${var.repo_name}:latest"
    ]
    cache_enabled = false
  }
}

resource "azurerm_container_registry_task" "fail" {
  name                  = "failure"
  container_registry_id = azurerm_container_registry.acr.id
  platform {
    os = "Linux"
  }
  docker_step {
    dockerfile_path      = "Doesnotexistfile"
    context_path         = "https://github.com/WorldHealthOrganization/ihrbenchmark.git"
    context_access_token = var.github_pat
    image_names = [
      "${var.repo_name}:failure",
    ]
  }
}
