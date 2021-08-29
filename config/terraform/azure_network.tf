//
// Azure Virtual Network concepts and best practices:
//   https://docs.microsoft.com/en-us/azure/virtual-network/concepts-and-best-practices
//   - Ensure non-overlapping address spaces.
//   - Your subnets should not cover the entire address space of the VNet.
//   - It is recommended you have fewer large VNets rather than multiple small VNets.
//   - TODO: Secure your VNets by assigning Network Security Groups (NSGs) to the subnets beneath them.
//
resource "azurerm_virtual_network" "primary" { // the primary back-of-house vnet
  name                = "vnet-primary"
  location            = azurerm_resource_group.who_ihr_benchmarks.location
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  address_space       = ["10.1.0.0/16"]
//  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}
resource "azurerm_subnet" "app_service_integration" {
  name = "subnet-app-service-integration"
  resource_group_name  = azurerm_resource_group.who_ihr_benchmarks.name
  virtual_network_name = azurerm_virtual_network.primary.name
  address_prefixes     = ["10.1.1.0/24"]
  delegation {
    name = "example-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
resource "azurerm_subnet" "app_critical_services" {
  name = "subnet-app-critical-services"
  resource_group_name  = azurerm_resource_group.who_ihr_benchmarks.name
  virtual_network_name = azurerm_virtual_network.primary.name
  address_prefixes     = ["10.1.3.0/24"]
}
resource "azurerm_network_interface" "network_tester" {
  name                = "nic-network-tester"
  location            = azurerm_resource_group.who_ihr_benchmarks.location
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app_critical_services.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "network_tester" {
  name                = "vm-network-tester"
  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
  location            = azurerm_resource_group.who_ihr_benchmarks.location
  size                = "Standard_B1ls"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.network_tester.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
resource "azurerm_virtual_machine_extension" "vm_ext_network_watcher_linux" {
  name                 = "vm-ext-network-watcher-linux"
  virtual_machine_id   = azurerm_linux_virtual_machine.network_tester.id
  publisher            = "Microsoft.Azure.NetworkWatcher"
  type                 = "NetworkWatcherAgentLinux"
  type_handler_version = "1.4"
}

//resource "azurerm_subnet" "subnet_for_build_support_services" {
//  name = "subnet-build-support-services"
//  resource_group_name  = azurerm_resource_group.who_ihr_benchmarks.name
//  virtual_network_name = azurerm_virtual_network.vnet_primary.name
//  address_prefixes     = ["10.1.2.0/24"]
//}


//resource "azurerm_subnet" "subnet_for_management" {
//  name = "subnet-management"
//  resource_group_name  = azurerm_resource_group.who_ihr_benchmarks.name
//  virtual_network_name = azurerm_virtual_network.vnet_primary.name
//  address_prefixes     = ["10.1.4.0/24"]
//}

