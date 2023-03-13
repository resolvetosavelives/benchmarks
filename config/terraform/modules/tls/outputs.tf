output "key_vault_id" {
  value       = var.create_key_vault ? azurerm_key_vault.agw[0].id : "null"
  description = "The id of the key vault created"
}
output "key_vault_name" {
  value       = var.create_key_vault ? azurerm_key_vault.agw[0].name : "null"
  description = "The name of the key vault created"
}
output "cert_name" {
  value       = var.create_key_vault ? azurerm_key_vault_certificate.cert[0].name : "null"
  description = "The name of the key vault cert created"
}
output "prod_managed_identity_id" {
  value       = azurerm_user_assigned_identity.prod.id
  description = "Name of the managed identity for prod with access to the key vault"
}
output "test_managed_identity_id" {
  value       = azurerm_user_assigned_identity.test.id
  description = "Name of the managed identity for test with access to the key vault"
}