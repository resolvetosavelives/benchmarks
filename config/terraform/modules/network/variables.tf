variable "resource_group_name" {
  description = "Resource group name containing all resources"
  type        = string
}
variable "location" {
  description = "The location of the resource group"
  type        = string
}
variable "namespace" {
  description = "namespace for all resource names (application name)"
  type        = string
}
variable "domain_name" {
  description = "The domain name to use for the temporary self-signed cert. We will eventually use a properly signed cert provided by the WHO"
  type        = string
}
variable "key_vault_developer_group" {
  description = "The Azure user group that will be given permission to manage the vault"
  type        = string
}
variable "key_vault_developer_ips" {
  description = "The IPs that will be given permission to interact with the key vault"
  type        = map(string)
}
variable "tenant_id" {
  description = "The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Changing this forces a new resource to be created."
  type        = string
}
variable "object_id" {
  description = "The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Changing this forces a new resource to be created."
  type        = string
}
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
variable "debug_mode" {
  description = "When true, install additional debug tooling like a bastion host and jumpbox with debugging tools"
  type        = bool
  default     = false
}