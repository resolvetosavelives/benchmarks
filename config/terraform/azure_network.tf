
resource "azurerm_virtual_network" "primary" { // the primary back-of-house vnet
  name                = "vnet-primary"
  location            = azurerm_resource_group.who_ihr_benchmarks.location
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  address_space       = ["10.0.0.0/16"]
}
// Azure reserves the first four addresses in each subnet address range.
// The addresses can't be assigned to resources. For example, if the subnet's
// address range is 10.0.0.0/16, addresses 10.0.0.0-10.0.0.3 and 10.0.255.255 are unavailable.
resource "azurerm_subnet" "subnet_gateway" {
  name                 = "GatewaySubnet" // NB: must be named "GatewaySubnet" or disallowed from using Azure VNet Gateway
  resource_group_name  = azurerm_resource_group.who_ihr_benchmarks.name
  virtual_network_name = azurerm_virtual_network.primary.name
  address_prefixes     = ["10.0.1.0/24"]
#  service_endpoints    = ["Microsoft.Sql"]
}
resource "azurerm_subnet" "app_service_integration" {
  name                 = "subnet-app-service-integration"
  resource_group_name  = azurerm_resource_group.who_ihr_benchmarks.name
  virtual_network_name = azurerm_virtual_network.primary.name
  address_prefixes     = ["10.0.2.0/24"]
  // service_endpoints has made no difference so far other than App Service comes from 0.0.0.0
#  service_endpoints    = ["Microsoft.Sql"]
  delegation {
    name = "subnet-delegation-for-app-service-integration"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
resource "azurerm_subnet" "app_critical_services" {
  name                 = "subnet-app-critical-services"
  resource_group_name  = azurerm_resource_group.who_ihr_benchmarks.name
  virtual_network_name = azurerm_virtual_network.primary.name
  address_prefixes     = ["10.0.3.0/24"]
#  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_public_ip" "pip_vpn_primary" {
  name                    = "pip-vpn-primary"
  location                = azurerm_resource_group.who_ihr_benchmarks.location
  resource_group_name     = azurerm_resource_group.who_ihr_benchmarks.name
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = "15"
  // 20.69.213.38 as of Wed 2021-09-01 7pm ET
}
resource "azurerm_virtual_network_gateway" "vngateway_primary" {
  name                = "vngateway-primary"
  location            = azurerm_resource_group.who_ihr_benchmarks.location
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  // can be: "Basic", "Standard", "VpnGw1"
  // but must be higher than "Basic" to work with MacOS.
  sku = "VpnGw1"
  ip_configuration {
    name                          = "vnet-gateway-config"
    public_ip_address_id          = azurerm_public_ip.pip_vpn_primary.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet_gateway.id
  }
  vpn_client_configuration {
    address_space        = ["172.17.203.0/24"]
    vpn_client_protocols = ["IkeV2", "OpenVPN"]
    root_certificate {
      name             = "P2SRootCert"
      public_cert_data = "MIIC5jCCAc6gAwIBAgIIKxl+bDvbTx4wDQYJKoZIhvcNAQELBQAwETEPMA0GA1UEAxMGVlBOIENBMB4XDTIxMDgzMTE3NTEyOFoXDTI0MDgzMDE3NTEyOFowETEPMA0GA1UEAxMGVlBOIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAztkhA75XehmbT2VrvFiXQSvw6IgPOk1wO+T331IH4llBlYLByVLsWlFMB5GtoUdQRypXhpwaq/j2r4HaTK94j4A4T9uNEmQsMU/Xs5U0TghZHyPxbmkjoKNdhj6VeburNK8kkIzskXUGLQtyQ6SmzXH/6xxaSb/29iPMpLzGpY0OAHueYZ0lg70xg/C+0IP88Dl/yw7IHkb2T396gUqhmifXpPsGaIRd9nxPGF03S5fQeaVkCLtMsb03jaLXPYBO5XyK7mYcxui5MuPO/v7omh3wJ+c9qslgqZMDsY1cvmi7Vx+HDBocAlqukJ1qvKWYBE3HW+Eo9baOuaKtsPmHrQIDAQABo0IwQDAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUQrbGBPRpPkqBDPSVXqpNdaqDO6kwDQYJKoZIhvcNAQELBQADggEBAKTNO+Au4rCu/u6JCx04jyyv/w01goOMbdtxTM9SGNBmQaGUbGQkIc/+jEtTl6i310l9us2Ut3WR2XvI+XKO17O4fk77xOVbRp48QVuhr4mXtdi2gRt1ykZL489HzA9ml0fif7TwQzv00QOG0Hbag9ZXNjlJqrF2nPAHA98xPJsHTQ76TuHSALhjF1IN1jQ553oC91rqqo18TUmukWEf/DtlYKwsmjQZI75MnBR6YvmLsWCd4LqSeJe0Vd1t5nK91aD8+Sb6DMyKWiPLKUkk8J4owZmoJcsCS718iFDdHqQ1J0rpT+GZmEDvQarIdZiHnQwXIovyFny9Pho6aT7KD30="
    }
  }
}
