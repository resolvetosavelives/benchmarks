resource "azurerm_subnet" "service" {
  name                 = "${var.namespace}-service-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.15.1.0/24"]
  service_endpoints    = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "ci_agent" {
  name                 = "${var.namespace}-ci-agent-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.15.2.0/24"]
}

resource "azurerm_subnet" "app" {
  name                 = "${var.namespace}-app-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.15.3.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# This subnet is used for the private endpoint for the app. The private endpoint can't be in the same subnet as the app delegation, nor in the same subnet as the gateway.
resource "azurerm_subnet" "app_private_endpoint" {
  name                 = "${var.namespace}-endpoint-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.15.4.0/24"]
}

/*
* This subnet is used for outbound traffic from the app. It's the vnet integration subnet
* https://learn.microsoft.com/en-us/azure/architecture/example-scenario/private-web-app/private-web-app
* However, in order for outbound traffic during the app configuration stage to reach the database
* (to set up the database when starting up the app), you must run two manual commands via the CLI

The first one enables the app to access the container registry during setup.
az resource update --resource-group <group-name> --name <app-name> --resource-type "Microsoft.Web/sites" --set properties.vnetImagePullEnabled=true

The second command enables the app to access the database during setup.
az resource update --resource-group <group-name> --name <app-name> --resource-type "Microsoft.Web/sites" --set properties.vnetRouteAllEnabled=true

These commands must be run for both UAT and Prod, when the integration is made.
*
*/
resource "azurerm_subnet" "app_vnet_integration_endpoint" {
  name                 = "${var.namespace}-app-outbound-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.15.6.0/24"]
  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}