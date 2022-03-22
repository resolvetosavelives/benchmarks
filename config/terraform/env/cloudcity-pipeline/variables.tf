variable "location" {
  description = "Azure region for the resource groups"
  type        = string
  default     = "westeurope"
}
variable "RAILS_MASTER_KEY" {
  description = "Rails master key from config/master.key"
  type        = string
  sensitive   = true
}
variable "organization_prefix" {
  description = "Organization prefix for globally unique names (e.g. 'who')"
  type        = string
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
variable "devops_project_name" {
  description = "DevOps project name (for the Azure DevOps project)"
  type        = string
  default     = "IHRBENCHMARK"
}
variable "repository_id" {
  description = "GitHub org/repo"
  type        = string
  default     = "WorldHealthOrganization/ihrbenchmark"
}
