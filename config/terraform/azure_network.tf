//
// Azure Virtual Network concepts and best practices:
//   https://docs.microsoft.com/en-us/azure/virtual-network/concepts-and-best-practices
//   - Ensure non-overlapping address spaces.
//   - Your subnets should not cover the entire address space of the VNet.
//   - It is recommended you have fewer large VNets rather than multiple small VNets.
//   - TODO: Secure your VNets by assigning Network Security Groups (NSGs) to the subnets beneath them.
//
// VPN Gateway Type, spupports OpenVPN: VpnGw1

resource "azurerm_virtual_network" "primary" { // the primary back-of-house vnet
  name                = "vnet-primary"
  location            = azurerm_resource_group.who_ihr_benchmarks.location
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  address_space       = ["10.0.0.0/16"]
//  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}
//resource "azurerm_private_dns_zone" "pdns_acr01" {
//  name                = "privatelink.azurecr.io"
//  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
//}
//resource "azurerm_private_dns_zone_virtual_network_link" "pdnslink_acr01_primary" {
//  name                  = "test"
//  resource_group_name   = azurerm_resource_group.who_ihr_benchmarks.name
//  private_dns_zone_name = azurerm_private_dns_zone.pdns_acr01.name
//  virtual_network_id    = azurerm_virtual_network.primary.id
//}
//resource "azurerm_subnet" "build_support_services" {
//  name = "subnet-build-support-services"
//  resource_group_name  = azurerm_resource_group.who_ihr_benchmarks.name
//  virtual_network_name = azurerm_virtual_network.primary.name
//  address_prefixes     = ["10.3.0.0/24"]
//  enforce_private_link_endpoint_network_policies = true
//  service_endpoints = ["Microsoft.ContainerRegistry"]
//}
resource "azurerm_subnet" "app_critical_services" {
  name = "subnet-app-critical-services"
  resource_group_name  = azurerm_resource_group.who_ihr_benchmarks.name
  virtual_network_name = azurerm_virtual_network.primary.name
  address_prefixes     = ["10.0.3.0/24"]
  enforce_private_link_endpoint_network_policies = true
//  service_endpoints = ["Microsoft.Sql"]
}
//resource "azurerm_subnet" "app_service_integration" {
//  name = "subnet-app-service-integration"
//  resource_group_name  = azurerm_resource_group.who_ihr_benchmarks.name
//  virtual_network_name = azurerm_virtual_network.primary.name
//  address_prefixes     = ["10.1.1.0/24"]
//  enforce_private_link_endpoint_network_policies = true
//  delegation {
//    name = "example-delegation"
//
//    service_delegation {
//      name    = "Microsoft.Web/serverFarms"
//      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
//    }
//  }
//}
resource "azurerm_subnet" "subnet_gateway" {
  name = "GatewaySubnet" // NB: must be named "GatewaySubnet" or disallowed from using Azure VNet Gateway
  resource_group_name  = azurerm_resource_group.who_ihr_benchmarks.name
  virtual_network_name = azurerm_virtual_network.primary.name
  address_prefixes     = ["10.0.1.0/24"]
//  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_public_ip" "pip_vpn_primary" {
  name = "pip-vpn-primary"
  location            = azurerm_resource_group.who_ihr_benchmarks.location
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  allocation_method   = "Static"
  sku = "Standard"
  idle_timeout_in_minutes = "15"
  // as of Tue 2021-08-31 6:55pm ET : 20.69.213.38
}
//// from https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal
////   The Basic gateway SKU does not support IKEv2 or RADIUS authentication.
////   If you plan on having Mac clients connect to your virtual network, do not use the Basic SKU.
resource "azurerm_virtual_network_gateway" "vngateway_primary" {
  name                = "vngateway-primary"
  location            = azurerm_resource_group.who_ihr_benchmarks.location
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1" # can be: "Basic", "Standard", "VpnGw1"

  ip_configuration {
    name                          = "vnet-gateway-config"
    public_ip_address_id          = azurerm_public_ip.pip_vpn_primary.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet_gateway.id
  }

  vpn_client_configuration {
    address_space = ["172.17.203.0/24"]
    vpn_client_protocols = ["IkeV2", "OpenVPN"]
    root_certificate {
      name = "P2SRootCert"
      public_cert_data = "MIIC5jCCAc6gAwIBAgIIKxl+bDvbTx4wDQYJKoZIhvcNAQELBQAwETEPMA0GA1UEAxMGVlBOIENBMB4XDTIxMDgzMTE3NTEyOFoXDTI0MDgzMDE3NTEyOFowETEPMA0GA1UEAxMGVlBOIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAztkhA75XehmbT2VrvFiXQSvw6IgPOk1wO+T331IH4llBlYLByVLsWlFMB5GtoUdQRypXhpwaq/j2r4HaTK94j4A4T9uNEmQsMU/Xs5U0TghZHyPxbmkjoKNdhj6VeburNK8kkIzskXUGLQtyQ6SmzXH/6xxaSb/29iPMpLzGpY0OAHueYZ0lg70xg/C+0IP88Dl/yw7IHkb2T396gUqhmifXpPsGaIRd9nxPGF03S5fQeaVkCLtMsb03jaLXPYBO5XyK7mYcxui5MuPO/v7omh3wJ+c9qslgqZMDsY1cvmi7Vx+HDBocAlqukJ1qvKWYBE3HW+Eo9baOuaKtsPmHrQIDAQABo0IwQDAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUQrbGBPRpPkqBDPSVXqpNdaqDO6kwDQYJKoZIhvcNAQELBQADggEBAKTNO+Au4rCu/u6JCx04jyyv/w01goOMbdtxTM9SGNBmQaGUbGQkIc/+jEtTl6i310l9us2Ut3WR2XvI+XKO17O4fk77xOVbRp48QVuhr4mXtdi2gRt1ykZL489HzA9ml0fif7TwQzv00QOG0Hbag9ZXNjlJqrF2nPAHA98xPJsHTQ76TuHSALhjF1IN1jQ553oC91rqqo18TUmukWEf/DtlYKwsmjQZI75MnBR6YvmLsWCd4LqSeJe0Vd1t5nK91aD8+Sb6DMyKWiPLKUkk8J4owZmoJcsCS718iFDdHqQ1J0rpT+GZmEDvQarIdZiHnQwXIovyFny9Pho6aT7KD30="
    }
  }
}
