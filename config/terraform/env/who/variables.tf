variable "location" {
  description = "Azure region for the resource group"
  type        = string
  default     = "westeurope"
}
variable "main_resource_group_name" {
  description = "Main resource group name (which holds the tfstate storage)"
  type        = string
  default     = "IHRBENCHMARK-MAIN-WEU-RG01"
}
variable "prod_resource_group_name" {
  description = "Primary resource group name (holds all production/staging/dev resources)"
  type        = string
  default     = "IHRBENCHMARK-P-WEU-RG01"
}
variable "test_resource_group_name" {
  description = "Test resource group name (for testing terraform, theoretically)"
  type        = string
  default     = "IHRBENCHMARK-T-WEU-RG01"
}
variable "organization" {
  description = "Organization prefix for globally unique names (e.g. 'who')"
  type        = string
  default     = "who"
}
variable "RAILS_MASTER_KEY" {
  description = "Rails master key from config/master.key"
  type        = string
  sensitive   = true
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
  default     = "761512b7-967d-46f4-81a1-96faac9d561e"
}
variable "azure_pipelines_yml_path" {
  description = "Path to the azure-pipelines.yml file"
  type        = string
  default     = "azure-pipelines.yml"
}
variable "azure_auth_application_id_staging" {
  description = "Azure Auth Application ID (staging)"
  type        = string
}
variable "azure_auth_application_id_preview" {
  description = "Azure Auth Application ID (preview)"
  type        = string
}
variable "azure_auth_application_id_production" {
  description = "Azure Auth Application ID (production)"
  type        = string
}
variable "azure_auth_client_secret_staging" {
  description = "Azure Auth Client Secret (staging)"
  type        = string
  sensitive   = true
}
variable "azure_auth_client_secret_preview" {
  description = "Azure Auth Client Secret (preview)"
  type        = string
  sensitive   = true
}
variable "azure_auth_client_secret_production" {
  description = "Azure Auth Client Secret (production)"
  type        = string
  sensitive   = true
}
