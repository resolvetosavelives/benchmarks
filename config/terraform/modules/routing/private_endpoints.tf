locals {
  subnet_cidr = var.subnet_prefixes[0]
  # Azure reserves the first 10 ips of a subnet. This ensures we pick an ip larger than that
  subnet_without_reserved_ips = cidrsubnet(local.subnet_cidr, 6, 3)
  app_private_ip              = cidrhost(local.subnet_without_reserved_ips, 0)
  db_private_ip               = cidrhost(local.subnet_without_reserved_ips, 1)
  acr_private_ip              = cidrhost(local.subnet_without_reserved_ips, 2)
}

resource "azurerm_private_endpoint" "app-endpoint" {
  name                = "${var.namespace}-app-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  private_service_connection {
    is_manual_connection           = false
    name                           = "${var.namespace}-app-endpoint-sc"
    private_connection_resource_id = var.app_id
    subresource_names              = ["sites"]
  }
  ip_configuration {
    name               = "${var.namespace}-app-endpoint"
    private_ip_address = local.app_private_ip
    subresource_name   = "sites"
  }
  private_dns_zone_group {
    name                 = "${var.namespace}-app-endpoint-default"
    private_dns_zone_ids = [var.app_dns_zone_id]
  }
}
resource "azurerm_private_dns_a_record" "app_endpoint" {
  name                = var.namespace
  resource_group_name = var.resource_group_name
  zone_name           = var.app_dns_zone_name
  ttl                 = 15
  records             = [local.app_private_ip]
}

resource "azurerm_private_endpoint" "db_endpoint" {
  name                = "${var.namespace}-db-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  private_service_connection {
    is_manual_connection           = false
    name                           = "${var.namespace}-db-endpoint-sc"
    private_connection_resource_id = var.db_id
    subresource_names              = ["postgresqlServer"]
  }
  ip_configuration {
    name               = "${var.namespace}-db-endpoint"
    private_ip_address = local.db_private_ip
    subresource_name   = "postgresqlServer"
  }
  private_dns_zone_group {
    name                 = "${var.namespace}-db-endpoint-default"
    private_dns_zone_ids = [var.db_dns_zone_id]
  }
}
resource "azurerm_private_dns_a_record" "db_endpoint" {
  name                = var.db_fqdn
  resource_group_name = var.resource_group_name
  zone_name           = var.db_dns_zone_name
  ttl                 = 15
  records             = [local.db_private_ip]
}

/**
 * We created this resource manually. However, there are some bugs in the TF provider that make it impossible to
 * correctly create or manage this resource right now with TF.
 *
 * The issues are fixed in [this PR](https://github.com/hashicorp/terraform-provider-azurerm/pull/19389) which has not shipped yet.
 * One that ships, try uncommenting this out, importing the resources to tf state, and matching the existing resource configs, and see if that works.
**/
#resource "azurerm_private_endpoint" "acr_endpoint" {
#  name                = "${var.namespace}-acr-endpoint"
#  location            = var.location
#  resource_group_name = var.resource_group_name
#  subnet_id           = var.subnet_id
#  custom_network_interface_name = "${var.namespace}-acr-endpoint-nic"
#
#  private_service_connection {
#    is_manual_connection           = false
#    name                           = "${var.namespace}-acr-endpoint"
#    private_connection_resource_id = var.acr_id
#    subresource_names              = ["registry"]
#  }
#
#  ip_configuration {
#    name               = "${var.namespace}.westeurope.data"
#    private_ip_address = "xx.xx.x.xx"
#    subresource_name   = "registry"
#  }
#  ip_configuration {
#    name               = "${var.namespace}"
#    private_ip_address = "xx.xx.x.xx"
#    subresource_name   = "registry"
#}
#  private_dns_zone_group {
#    id                   = "/subscriptions/974ebced-5bea-4fa8-af6f-7064aa3eccff/resourceGroups/IHRBENCHMARK-T-WEU-RG01/providers/Microsoft.Network/privateEndpoints/who-ihrbenchmark-uat-acr-endpoint/privateDnsZoneGroups/default"
#    name                 = "default"
#    private_dns_zone_ids = [
#      "/subscriptions/974ebced-5bea-4fa8-af6f-7064aa3eccff/resourceGroups/IHRBENCHMARK-T-WEU-RG01/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io",
#    ]
#  }
#}
