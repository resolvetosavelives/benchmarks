output "database_url" {
  value       = local.database_url
  description = "DATABASE_URL string"
  sensitive   = true
}
output "preview_database_url" {
  value       = local.preview_database_url
  description = "DATABASE_URL string for preview slot"
  sensitive   = true
}
