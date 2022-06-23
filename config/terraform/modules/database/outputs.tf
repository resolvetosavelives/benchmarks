output "database_url" {
  value       = local.database_url
  description = "DATABASE_URL string"
  sensitive   = true
}
