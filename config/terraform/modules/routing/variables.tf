variable "resource_group_name" {
  description = "Resource group name containing all resources"
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
variable "app_id" {
  description = "The id of the IHRBenchmarks app to bind with the private endpoint. The ID should be of the form /subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Web/sites/ccd-ihrbenchmark"
  type        = string
}
variable "db_id" {
  description = "The id of the IHRBenchmarks postgres database to bind with the private endpoint."
  type        = string
}
variable "db_fqdn" {
  description = "The fqdn used in setting up the database url. This should later be used in the routing module to make a dns record in the private dns zone pointing to the private endpoint"
  type        = string
}
variable "vnet_id" {
  description = "The id of the VNET. This will be used to link the dns zone, but should also contain the subnet whose ID was provided"
  type        = string
}
variable "subnet_id" {
  description = "The id of the subnet for the private endpoint for the app service"
  type        = string
}
variable "subnet_prefixes" {
  description = "A list of cidr address prefixes for the subnet which will have the private endpoint"
  type        = list(string)
}
variable "app_dns_zone_id" {
  description = "The DNS zone to create the private endpoint for the app DNS record in"
  type        = string
}
variable "app_dns_zone_name" {
  description = "The name of the app private dns zone linked to the vnet. It will be needed to create the dns entry for the private endpoint."
  type        = string
}
variable "db_dns_zone_id" {
  description = "The DNS zone to create the private endpoint for the dB DNS record in"
  type        = string
}
variable "db_dns_zone_name" {
  description = "The name of the db private dns zone linked to the vnet. It will be needed to create the dns entry for the app private endpoint."
  type        = string
}
variable "acr_id" {
  description = "The id of the IHRBenchmarks container registry to bind with the private endpoint."
  type        = string
}