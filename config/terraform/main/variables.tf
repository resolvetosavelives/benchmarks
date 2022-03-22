variable "organization_prefix" {
  description = "Organization prefix for globally unique names (e.g. 'who')"
  type        = string
}
variable "devops_project_name" {
  description = "Azure DevOps project name"
  type        = string
  default     = "IHRBENCHMARK"
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
