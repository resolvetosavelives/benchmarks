variable "organization" {
  type = string
}
variable "RAILS_MASTER_KEY" {
  type      = string
  sensitive = true
}
variable "devops_project_name" {
  type = string
}
variable "prod_resource_group_name" {
  type = string
}
variable "test_resource_group_name" {
  type = string
}
