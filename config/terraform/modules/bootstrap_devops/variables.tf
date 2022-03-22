variable "RAILS_MASTER_KEY" {
  description = "Rails master key from config/master.key"
  type        = string
  sensitive   = true
}
variable "organization_prefix" {
  description = "Organization prefix for globally unique names (e.g. 'who')"
  type        = string
}
variable "location" {
  description = "Azure region for the resource group"
  type        = string
  default     = "westeurope"
}
variable "devops_project_name" {
  description = "Azure DevOps project name"
  type        = string
  default     = "IHRBENCHMARK"
}
variable "github_repo_id" {
  description = "GitHub org/repo"
  type        = string
  default     = "WorldHealthOrganization/ihrbenchmark"
}
variable "github_branch" {
  description = "Git branch to build"
  type        = string
  default     = "refs/heads/main"
}
variable "github_service_connection_id" {
  description = "GitHub Service Connection UUID - In Project Settings, click on the GitHub service connection created by the Azure Pipelines GitHub App and copy the UUID from the URL"
  type        = string
}
variable "azure_pipelines_yml_path" {
  description = "Path to the azure-pipelines.yml file"
  type        = string
  default     = "azure-pipelines.yml"
}
variable "terraform_resource_group_name" {
  description = "tfstate resource group name"
  type        = string
}
variable "terraform_storage_account_name" {
  description = "tfstate storage account name"
  type        = string
}
variable "terraform_container_name" {
  description = "tfstate blob storage container name"
  type        = string
}
