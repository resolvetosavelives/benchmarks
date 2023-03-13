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
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
variable "cert_name" {
  description = "The name to give the cert in the application gateway's cert list. This could be any string. We pass it in so that we can use a more descriptive name for the source of the cert"
  type        = string
}
variable "key_vault_name" {
  description = "The name for the key vault. This will be used to make the key vault (if one is being made) and to create the key_vault_secret_id"
  type        = string
}
variable "managed_identity_id" {
  description = "The id of a managed identity which has access to the key vault where the cert lives"
  type        = string
}
variable "subnet_id" {
  description = "The id of the subnet to put the application gateway in. This subnet can ONLY have application gateways in it"
  type        = string
}
variable "public_ip_id" {
  description = "The id of the public ip for this gateway"
  type        = string
}
variable "domain_name" {
  description = "The external domain name this gateway will respond to"
  type        = string
}
