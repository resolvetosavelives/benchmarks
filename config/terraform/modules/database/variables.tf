variable "resource_group_name" {
  type = string
}
variable "location" {
  description = "The location of the resource group"
  type        = string
}
variable "namespace" {
  type = string
}
variable "database_name" {
  type = string
}
variable "developer_ips" {
  type = map(string)
}
variable "fqdn" {
  type        = string
  description = "The domain name. For the endpoint, this will be a private endpoint value. This is only configurable so we can test the private endpoint in staging"
}