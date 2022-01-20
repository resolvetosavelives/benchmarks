#
# SECTION: Variables used
#
variable "ORGANIZATION" {
  type      = string
  sensitive = false
}
variable "RAILS_MASTER_KEY" {
  type      = string
  sensitive = true
}
