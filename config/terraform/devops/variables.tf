variable "DATABASE_URL" {
  type      = string
  sensitive = true
}
variable "DEVOPS_DOCKER_ACR_SERVICE_CONNECTION_NAME" {
  type = string
}
variable "GITHUB_SERVICE_CONNECTION_ID" {
  type = string
}
variable "GITHUB_REPO" {
  type = string
}
variable "GITHUB_BRANCH" {
  type = string
}
variable "RAILS_MASTER_KEY" {
  type      = string
  sensitive = true
}
