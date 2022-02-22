output "staging_database_url" {
  value       = local.staging_database_url
  description = "DATABASE_URL string for staging database"
  sensitive   = true
}

output "production_database_url" {
  value       = local.production_database_url
  description = "DATABASE_URL string for production database"
  sensitive   = true
}
