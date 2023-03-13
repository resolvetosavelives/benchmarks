output "database_url" {
  value       = local.database_url
  description = "DATABASE_URL string"
  sensitive   = true
}
output "database_id" {
  value       = azurerm_postgresql_server.db.id
  description = "Azure id of the database, needed for private endpoint"
}

output "database_fqdn" {
  value       = local.database_fqdn
  description = "The fqdn used in setting up the database url. This should later be used in the routing module to make a dns record in the private dns zone pointing to the private endpoint"
}