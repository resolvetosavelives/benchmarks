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
  default     = "ccd"
}
variable "RAILS_MASTER_KEY" {
  description = "Rails master key from config/master.key"
  type        = string
  sensitive   = true
}
variable "devops_project_id" {
  description = "Azure DevOps project cloudcitydev/IHRBENCHMARK ID"
  type        = string
  default     = "36d18af8-b292-46f5-8254-18bdfdd1a883"
}
variable "github_repo_id" {
  description = "GitHub org/repo"
  type        = string
  default     = "resolvetosavelives/benchmarks"
}
variable "github_branch" {
  description = "Git branch to build"
  type        = string
  default     = "refs/heads/main"
}
variable "github_service_connection_id" {
  description = "GitHub Service Connection UUID - In Project Settings, click on the GitHub service connection created by the Azure Pipelines GitHub App and copy the UUID from the URL"
  type        = string
  default     = "b44e1ce6-53fb-43ad-abc4-c7407815bdc0"
}
variable "azure_pipelines_yml_path" {
  description = "Path to the azure-pipelines.yml file"
  type        = string
  default     = "azure-pipelines.yml"
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
  description = "Public SSH key for exploratory setting up of ci agent. This will (possibly) be removed once the ci agent is no longer exploratory"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDcw4REOTLYcglcTiift/tsLD0D6HZ/EvKMgPAo/jvI4RZVAhUYGQfNS81rD/worU9U46ifz3oC4ym1TZn1v3upKYLdCDaCbsDWnoxffEs7zWqZu+mgD6W2ZKUf6S0kzxXxMVti25XRmLjrxyOakWk/OnUVHYd4qVhE070OJNUON0xzpJMYPR20D5V2NJtFr6pI4Y9Hs4+4PfayRfuOfuoN5pQt4H4uLqMZO7h3XEgItxTmC0fHq5FlRIFcn84JnmWykQBjhcxhTcrF0lk4piUN967W7weY2T7ql0NTnAEPa0AAolJgVYoLk9uHrm408vBXpz/Se9v1zjn7YRvz/jiCioUWxI4fcJBCnpMPZoQPyU/QA4xAsj7gFc1QR7nsyJd06IvZNlPhpsG9hPVAbMPsTaD4Rzj5y6nv/oo74gP+5hHmP5tiF5Q6u/Pzqxt0xfG3f5u9nd7NKnIeM+EwHKzW8qZrM61bZnMXuQE+XE/uJ1XfYaI8Q52KiZMTX/AONZ8= caroline@cloudcity.io"
}
variable "tenant_id" {
  description = "A tenant represents a user or an organization. (A subscription is a billing unit, a tenant is a logical unit)"
  type        = string
  default     = "4efe96cc-3e99-409d-8d0e-432bd2ad9fce"
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
  default     = "ihrbenchmarks-uat.example.com" # Obviously fake, I have not put any thought into what this should be, because we may not use this env much anymore
}
variable "domain_name" {
  description = "The domain name to use for the temporary self-signed cert. We will eventually use a properly signed cert provided by the WHO"
  type        = string
  default     = "ihrbenchmarks.example.com" # Obviously fake, I have not put any thought into what this should be, because we may not use this env much anymore
}
variable "email_from" {
  description = "The no-reply email from which to send emails"
  type        = string
  default     = "no-reply@resolvetosavelives.org"
}
variable "admin_email_uat" {
  description = "The admin email to send notifications about new users who signed up for the UAT env. This is probably the primary dev's personal email"
  type        = string
  default     = "cain+cloudcity-uat-admin@cloudcity.io"
}
variable "admin_email_prod" {
  description = "The admin email to send notifications about new users who signed up for the prod env"
  type        = string
  default     = "cain+cloudcity-admin@cloudcity.io"
}
variable "developer_group" {
  description = "UUID of developer Azure group for permission-granting"
  type        = string
  default     = "d3ffeea2-4f1f-4bc9-9513-e10960bb57cb"
}
variable "sendgrid_api_key" {
  description = "The API key to use to connect to the sendgrid api"
  type        = string
  sensitive   = true
}
