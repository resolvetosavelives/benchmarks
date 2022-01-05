#
# SECTION: Variables used
#
variable "ORGANIZATION" {
  type      = string
  sensitive = false
}
variable "DATABASE_URL_FOR_PIPELINE" {
  type      = string
  sensitive = true
}
variable "DATABASE_URL_FOR_STAGING" {
  type      = string
  sensitive = true
}
variable "DATABASE_URL_FOR_PRODUCTION" {
  type      = string
  sensitive = true
}
variable "DEVOPS_GITHUB_SERVICE_CONNECTION_NAME" {
  type      = string
  sensitive = false
}
variable "DOCKER_REGISTRY_SERVER_URL" {
  type = string
}
variable "DOCKER_REGISTRY_SERVER_USERNAME" {
  type      = string
  sensitive = true
}
variable "DOCKER_REGISTRY_SERVER_PASSWORD" {
  type      = string
  sensitive = true
}
variable "GITHUB_REPO" {
  type      = string
  sensitive = false
}
variable "GITHUB_BRANCH" {
  type      = string
  sensitive = false
}
variable "RAILS_MASTER_KEY" {
  type      = string
  sensitive = true
}
