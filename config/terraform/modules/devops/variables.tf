variable "resource_group_name" {
  description = "Resource group name for target of deployment"
  type        = string
}
variable "devops_project_name" {
  description = "Azure DevOps project name"
  type        = string
}
variable "app_service_name" {
  description = "App service name for running app service pipeline tasks"
  type        = string
}
variable "container_registry_domain" {
  description = "Container registry domain from ACR"
  type        = string
}
variable "container_registry_username" {
  description = "Container registry username"
  type        = string
}
variable "container_registry_password" {
  description = "Container registry password"
  type        = string
  sensitive   = true
}
variable "container_repository" {
  description = "Container registry repository name"
  type        = string
}
variable "github_repo_id" {
  description = "GitHub org/repo"
  type        = string
}
variable "github_branch" {
  description = "Git branch to build"
  type        = string
}
variable "github_service_connection_id" {
  description = "GitHub Service Connection UUID - In Project Settings, click on the GitHub service connection created by the Azure Pipelines GitHub App and copy the UUID from the URL"
  type        = string
}
variable "azure_pipelines_yml_path" {
  description = "Path to the azure-pipelines.yml file"
  type        = string
}
