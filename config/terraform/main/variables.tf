variable "prod_resource_group_name" {
  description = "Primary resource group name (holds all production/staging/dev resources)"
  type        = string
}
variable "test_resource_group_name" {
  description = "Test resource group name (for testing terraform, theoretically)"
  type        = string
}
variable "organization" {
  description = "Organization prefix for globally unique names (e.g. 'who')"
  type        = string
}
variable "RAILS_MASTER_KEY" {
  description = "Rails master key from config/master.key"
  type        = string
  sensitive   = true
}
variable "devops_project_name" {
  description = "Azure DevOps project name"
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
