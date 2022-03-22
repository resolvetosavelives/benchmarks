output "variable_group_name" {
  value       = azuredevops_variable_group.vars.name
  description = "Name of the variable group to include in azure-pipelines.yml"
}
