variable "tenant_id" {
  description = "Tenant ID to initialize provider"
  type        = string
}
variable "name" {
  description = "Name of the app registration"
  type        = string
}
variable "domain" {
  description = "The domain used in the redirect and logout urls"
  type        = string
}
