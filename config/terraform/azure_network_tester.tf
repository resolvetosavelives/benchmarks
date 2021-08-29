//resource "azurerm_network_interface" "network_tester" {
//  name                = "nic-network-tester"
//  location            = azurerm_resource_group.who_ihr_benchmarks.location
//  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
//
//  ip_configuration {
//    name                          = "internal"
//    subnet_id                     = azurerm_subnet.app_critical_services.id
//    private_ip_address_allocation = "Dynamic"
//  }
//}
//resource "azurerm_linux_virtual_machine" "network_tester" {
//  name                = "vm-network-tester"
//  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
//  location            = azurerm_resource_group.who_ihr_benchmarks.location
//  size                = "Standard_B1ls"
//  admin_username      = "adminuser"
//  network_interface_ids = [
//    azurerm_network_interface.network_tester.id,
//  ]
//
//  admin_ssh_key {
//    username   = "adminuser"
//    public_key = file("~/.ssh/id_rsa.pub")
//  }
//
//  os_disk {
//    caching              = "ReadWrite"
//    storage_account_type = "Standard_LRS"
//  }
//
//  source_image_reference {
//    publisher = "Canonical"
//    offer     = "UbuntuServer"
//    sku       = "16.04-LTS"
//    version   = "latest"
//  }
//}
//resource "azurerm_virtual_machine_extension" "vm_ext_network_watcher_linux" {
//  name                 = "vm-ext-network-watcher-linux"
//  virtual_machine_id   = azurerm_linux_virtual_machine.network_tester.id
//  publisher            = "Microsoft.Azure.NetworkWatcher"
//  type                 = "NetworkWatcherAgentLinux"
//  type_handler_version = "1.4"
//}
