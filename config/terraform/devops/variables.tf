variable "PROJECT_ID" {
  type      = string
  sensitive = false
}
variable "DATABASE_URL" {
  type      = string
  sensitive = true
}
variable "GITHUB_SERVICE_CONNECTION_ID" {
  type      = string
  sensitive = false
}
variable "DEVOPS_DOCKER_ACR_SERVICE_CONNECTION_NAME" {
  type      = string
  sensitive = false
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
