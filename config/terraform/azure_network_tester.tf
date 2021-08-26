//resource "azurerm_public_ip" "pip_build_subnet_tester" {
//  name                = "pip-build-subnet-tester"
//  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
//  location            = azurerm_resource_group.who_ihr_benchmarks.location
//  sku                 = "Standard"
//  allocation_method   = "Static"
//}
//resource "azurerm_network_interface" "build_subnet_tester" {
//  name                = "nic-build-subnet-tester-02"
//  location            = azurerm_resource_group.who_ihr_benchmarks.location
//  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
//
//  ip_configuration {
//    name                          = "ipconf-internal-static"
//    subnet_id                     = azurerm_subnet.build_support_services.id
//    private_ip_address_allocation = "Static"
//    private_ip_address            = "10.1.2.12"
//    public_ip_address_id          = azurerm_public_ip.pip_build_subnet_tester.id
//  }
//}
//resource "azurerm_linux_virtual_machine" "build_subnet_tester" {
//  name                = "vm-build-subnet-tester-02"
//  resource_group_name = azurerm_resource_group.who_ihr_benchmarks.name
//  location            = azurerm_resource_group.who_ihr_benchmarks.location
//  size                = "Standard_B1ls"
//  //  admin_username      = "adminuser"
//  network_interface_ids = [
//    azurerm_network_interface.build_subnet_tester.id,
//  ]
//  allow_extension_operations      = true
//  disable_password_authentication = false
//  admin_username                  = "6a0c7dB7cCf3"
//  admin_password                  = "fE26023eA70280695aEa"
//  //  admin_ssh_key {
//  //    username   = "adminuser"
//  //    public_key = file("~/.ssh/id_rsa.pub")
//  //  }
//  os_disk {
//    caching              = "ReadWrite"
//    storage_account_type = "Standard_LRS"
//  }
//  source_image_reference {
//    publisher = "Canonical"
//    offer     = "UbuntuServer"
//    sku       = "16.04-LTS"
//    version   = "latest"
//  }
//}
//resource "azurerm_virtual_machine_extension" "vm_ext_build_subnet_tester_linux" {
//  name                 = "vm-ext-build-subnet-tester-linux"
//  virtual_machine_id   = azurerm_linux_virtual_machine.build_subnet_tester.id
//  publisher            = "Microsoft.Azure.NetworkWatcher"
//  type                 = "NetworkWatcherAgentLinux"
//  type_handler_version = "1.4"
//}
