variable "prod_resource_group_name" {
  description = "Resource group name containing all resources for prod"
  type        = string
}
variable "test_resource_group_name" {
  description = "Resource group name containing all resources for test"
  type        = string
}
variable "location" {
  description = "The location of the resource group"
  type        = string
}
variable "namespace" {
  description = "Namespace for all resource names (application name)"
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
variable "subnet_id" {
  description = "The subnet in which to place the key vault (if we make one)"
  type        = string
}
variable "subject_alt_names" {
  description = "A list of the fqdns to set as subject alt names in the cert created (if a cert is created)"
  type        = list(string)
}
variable "cert_name" {
  description = "The name to give the cert in the application gateway's cert list. This could be any string. We pass it in so that we can use a more descriptive name for the source of the cert"
  type        = string
}
variable "key_vault_name" {
  description = "The name for the key vault. This will be used to make the key vault (if one is being made) and to create the key_vault_secret_id"
  type        = string
}
variable "create_key_vault" {
  description = "Should we create our own key vault? In some envs, we are using a key vault manually created. In others, we need to create one. However, the key vault and cert depends on things created in the network module so they cannot be pre-created in the top level module"
  type        = bool
}