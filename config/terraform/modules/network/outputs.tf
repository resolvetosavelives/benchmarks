output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "ID of the virtual network that was created by the module"
}

output "vnet_name" {
  value       = azurerm_virtual_network.vnet.name
  description = "Name of the virtual network that was created by the module"
}

output "app_subnet_id" {
  value       = azurerm_subnet.app.id
  description = "ID of the subnet that was created for the app to live in"
}

output "app_subnet_name" {
  value       = azurerm_subnet.app.name
  description = "Name of the subnet that was created for the app to live in"
}

output "service_subnet_id" {
  value       = azurerm_subnet.service.id
  description = "ID of the subnet that was created for services which do not reach out to the internet to live in"
}

output "service_subnet_name" {
  value       = azurerm_subnet.service.name
  description = "Name of the subnet that was created for services which do not reach out to the internet to live in"
}

output "ci_agent_subnet_id" {
  value       = azurerm_subnet.ci_agent.id
  description = "ID of the subnet for only the ci_agents"
}

output "ci_agent_subnet_name" {
  value       = azurerm_subnet.ci_agent.name
  description = "Name of the subnet for only the ci_agents"
}
output "gateway_ip_id" {
  value       = azurerm_public_ip.agw.id
  description = "The name of the public ip created for the application gateway"
}
output "gateway_ip_addr" {
  value       = azurerm_public_ip.agw.ip_address
  description = "The public ip created for the application gateway"
}
output "private_endpoint_subnet_id" {
  value       = azurerm_subnet.app_private_endpoint.id
  description = "The id of the subnet for the private endpoint for the app service"
}
output "private_endpoint_subnet_prefixes" {
  value       = azurerm_subnet.app_private_endpoint.address_prefixes
  description = "A list of cidr address prefixes for the subnet which will have the private endpoint"
}
output "app_dns_zone_id" {
  value       = azurerm_private_dns_zone.zone.id
  description = "The private dns zone for appslinked to the vnet. It will be needed to create the private endpoint dns record"
}
output "app_dns_zone_name" {
  value       = azurerm_private_dns_zone.zone.name
  description = "The name of the private dns zone for apps linked to the vnet. It will be needed to create the dns entry for the private endpoint."
}
output "db_dns_zone_id" {
  value       = azurerm_private_dns_zone.db-zone.id
  description = "The private dns zone for the db linked to the vnet. It will be needed to create the private endpoint dns record"
}
output "db_dns_zone_name" {
  value       = azurerm_private_dns_zone.db-zone.name
  description = "The name of the private dns zone for the db linked to the vnet. It will be needed to create the dns entry for the private endpoint."
}
output "app_outbound_subnet_id" {
  value       = azurerm_subnet.app_vnet_integration_endpoint.id
  description = "The subnet to do the app service vnet integration for outbound traffic from the app"
}