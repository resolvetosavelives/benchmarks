variable "resource_group_name" {
  type = string
}
variable "location" {
  description = "The location of the resource group"
  type        = string
}
variable "namespace" {
  description = "Namespace to prepend to all resource names (application name)"
  type        = string
}

variable "vnet_name" {
  type        = string
  description = "The pre-existing virtual network to place the ci agent in"
}

variable "subnet_id" {
  type        = string
  description = "The pre-existing subnet in the vnet to place the ci agent in. This should be a subnet with just the ci_agent(s) in it"
}

variable "ci_agent_public_key" {
  description = "Public SSH key for exploratory setting up of ci agent"
  type        = string
}
