variable "resource_group_name" {
  type = string
}
variable "location" {
  description = "The location of the resource group"
  type        = string
}
variable "app_name" {
  description = "App name for the name of the container registry"
  type        = string
}
variable "github_pat" {
  description = "This is a Github PAT. It needs all repo access (for private repos) though for public just read is fine. It is used to pull down the repo for the ACR task"
  type        = string
  sensitive   = true
}
variable "repo_name" {
  description = "The name of the repository/image to build and push in the task"
}
