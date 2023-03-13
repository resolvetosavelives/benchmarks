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
variable "devops_project_id" {
  description = "Azure DevOps project WHOHQ/IHRBENCHMARK ID"
  type        = string
  default     = "679f7d50-14c7-4b17-aea0-cc0e0452141b"
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
variable "azure_auth_application_id_production" {
  description = "Azure Auth Application ID"
  type        = string
}
variable "azure_auth_client_secret_staging" {
  description = "Azure Auth Client Secret (staging)"
  type        = string
  sensitive   = true
}
variable "azure_auth_client_secret_production" {
  description = "Azure Auth Client Secret"
  type        = string
  sensitive   = true
}
variable "avo_license_key" {
  description = "License key for integrating with Avohq.io"
  type        = string
  sensitive   = true
}
variable "avo_license_key_uat" {
  description = "License key for integrating with Avohq.io"
  type        = string
  sensitive   = true
}
variable "ci_agent_public_key" {
  description = "Public SSH key for exploratory setting up of ci agent"
  type        = string
}
variable "tenant_id" {
  description = "A tenant represents a user or an organization. (A subscription is a billing unit, a tenant is a logical unit)"
  type        = string
  default     = "f610c0b7-bd24-4b39-810b-3dc280afb590"
}
variable "github_pat" {
  description = "This is a Github PAT. It needs all repo access (for private repos) though for public just read is fine. It is used to pull down the repo for the ACR task"
  type        = string
  sensitive   = true
}
variable "github_pat_expiry" {
  description = "GitHub PAT expiry date in ISO 8601 format (YYYY-MM-DD)"
  type        = string
}
variable "uat_domain_name" {
  description = "The domain name to use for the temporary self-signed cert. We will eventually use a properly signed cert provided by the WHO"
  type        = string
  default     = "ihrbenchmark-uat.who.int"
}
variable "domain_name" {
  description = "The domain name to use for the temporary self-signed cert. We will eventually use a properly signed cert provided by the WHO"
  type        = string
  default     = "ihrbenchmark.who.int"
}
variable "email_from" {
  description = "The no-reply email from which to send emails"
  type        = string
  default     = "no-reply@resolvetosavelives.org"
}
variable "admin_email_uat" {
  description = "The admin email to send notifications about new users who signed up for the UAT env. This is probably the primary dev's personal email"
  type        = string
  default     = "cain+who-uat-admin@cloudcity.io"
}
variable "admin_email_prod" {
  description = "The admin email to send notifications about new users who signed up for the prod env"
  type        = string
  default     = "cain+who-admin@cloudcity.io"
}
variable "developer_group" {
  description = "UUID of developer Azure group for permission-granting"
  type        = string
  default     = "15ceaed1-0865-43f2-ab67-8c0337bf4d8d"
}
variable "sendgrid_api_key" {
  description = "The API key to use to connect to the sendgrid api"
  type        = string
  sensitive   = true
}
variable "uat_debug_mode" {
  description = "When true, install additional debug tooling in the UAT env like a bastion host and jumpbox with debugging tools."
  type        = bool
  default     = false
}
