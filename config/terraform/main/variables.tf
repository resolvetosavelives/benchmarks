variable "prod_resource_group_name" {
  description = "Primary resource group name (holds all production/staging/dev resources)"
  type        = string
}
variable "test_resource_group_name" {
  description = "Test resource group name (for testing terraform, theoretically)"
  type        = string
}
variable "location" {
  description = "The location of the resource group"
  type        = string
}
variable "organization" {
  description = "Organization prefix for globally unique names (e.g. 'who')"
  type        = string
}
variable "devops_project_id" {
  description = "Azure DevOps project ID"
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
variable "azure_auth_application_id_staging" {
  description = "Azure Auth Application ID (staging)"
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
variable "azure_auth_client_secret_production" {
  description = "Azure Auth Client Secret (production)"
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
  description = "The domain name to use for the temporary self-signed cert for the uat env. We will eventually use a properly signed cert provided by the WHO"
  type        = string
}
variable "domain_name" {
  description = "The domain name to use for the temporary self-signed cert for the prod env. We will eventually use a properly signed cert provided by the WHO"
  type        = string
}
variable "app_settings" {
  description = "A map of all the subscription level env vars for the app"
  type        = map(any)
  #  sensitive   = true
}
variable "admin_email_uat" {
  description = "The admin email to send notifications about new users who signed up for the UAT env. This is probably the primary dev's personal email"
  type        = string
}
variable "admin_email_prod" {
  description = "The admin email to send notifications about new users who signed up for the prod env"
  type        = string
}
variable "developer_ips" {
  description = "A list of developers and their IP addresses"
  type        = map(string)
  default     = {}
}
variable "developer_group" {
  description = "UUID of group containing developers, for permission-granting"
  type        = string
}
variable "prod_tags" {
  description = "Tags from the resource group to include on production resources. Currently just the application gateway but these should go everywhere"
  type        = map(string)
}
variable "uat_tags" {
  description = "Tags from the resource group to include on test resources. Currently just the application gateway but these should go everywhere"
  type        = map(string)
}
variable "create_key_vault" {
  description = "Should we create our own key vault? In some envs, we are using a key vault manually created. In others, we need to create one. However, the key vault and cert depends on things created in the network module so they cannot be pre-created in the top level module"
  type        = bool
}
variable "cert_name" {
  description = "The name to give the cert in the application gateway's cert list. This could be any string. We pass it in so that we can use a more descriptive name for the source of the cert"
  type        = string
}
variable "key_vault_name" {
  description = "The name for the key vault. This will be used to make the key vault (if one is being made) and to create the key_vault_secret_id"
  type        = string
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
