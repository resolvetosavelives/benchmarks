variable "location" {
  type    = string
  default = "westeurope"
}
variable "RAILS_MASTER_KEY" {
  type      = string
  sensitive = true
}
variable "prod_resource_group_name" {
  type    = string
  default = "IHRBENCHMARK-P-WEU-RG01"
}
variable "test_resource_group_name" {
  type    = string
  default = "IHRBENCHMARK-T-WEU-RG01"
}
variable "devops_project_name" {
  type    = string
  default = "IHRBENCHMARK"
}
