locals {
  debugging_rg = "debugging-resources-ct"
}
resource "azurerm_subnet" "bastion" {
  count                = var.debug_mode ? 1 : 0
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.15.5.0/26"]
}

resource "azurerm_public_ip" "jumpbox" {
  count = var.debug_mode ? 1 : 0

  name                = "${var.namespace}-jumpbox-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    debug = true
  }
}

resource "azurerm_bastion_host" "jumpbox" {
  count = var.debug_mode ? 1 : 0

  name                = "${var.namespace}-jumpbox"
  location            = var.location
  resource_group_name = var.resource_group_name
  tunneling_enabled   = true
  sku                 = "Standard"
  tags = {
    debug = true
  }

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion[0].id
    public_ip_address_id = azurerm_public_ip.jumpbox[0].id
  }
}

resource "azurerm_network_interface" "debug" {
  count = var.debug_mode ? 1 : 0

  name                = "${var.namespace}-debug-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ci_agent.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "debugger" {
  count = var.debug_mode ? 1 : 0

  name                = "${var.namespace}-debug-vm"
  location            = var.location
  resource_group_name = var.resource_group_name

  size           = "Standard_F2"
  admin_username = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.debug[0].id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDywzC1BfB8LzigeMzSTuV3NsOer3kV29xav934E4dlsJWJziyb1RoPaWGXY//6b17bUJ17DPmRxL1K4SHrzwWr77dVeJHKunKAJR/QPgfYL1MoDsk1HHEKZp/dPRiAkgbC/j2E+sCxW+OvQ9INKQX/oel1o3cUQMkTa+AiVdeKlNRnMtIYdPrJQItlk/uUM9HR0qHGMx/VK4rUGmVQJGWy0zaAbj6WSKNbXKE86ycOkPNMmt/CUq+2XngF+uf6VvUMZHomGqR1K5/0oDAOEtDtElZ5uDy6ODWYUjzPLLgCLqHvfP9eRijSMLCyVRHKCOpLojqeDhW+XsgkqiCjFWT9atoksDMc6t3VbzXjjEvWdBw3PCHDtsUPhWjficeiZGHgCO9s505VB45VQmjULnqMt8V16EPrEOdR9HEBMvnSYBYe3GrpP+Zkj4a7hWlNpYml+jYtBWVU937Hf9LiirsUFpXjbY2hp9wkiGxa3fFPKW1X50hH28zX0NaABF/eH17xvmSDS/mN9IZvAw3piafsYwMpjvvMDYktzPNkQ1S16VuvTwIju9DB1hU6oIzCBiGDUm6xl8dfUL5wyKL7UP5F0O1uZnASZGj9ltiHA4KwvAmgPBdN60ebVYsLqH7zp97kmrRf3kyYWR7DirE0xWaWLFTOnphBS/WkoL5JBPEqBw== ctaymor@gmail.com"
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

resource "azurerm_virtual_machine_extension" "install_debug_tools" {
  count                = var.debug_mode ? 1 : 0
  name                 = "install_debug_tools"
  virtual_machine_id   = azurerm_linux_virtual_machine.debugger[0].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  protected_settings = jsonencode({
    "script" = base64encode(<<SCRIPT
sudo apt-get install curl
sudo apt install postgresql-client-common postgresql
SCRIPT
    )
  })
  depends_on = [
    azurerm_linux_virtual_machine.debugger[0]
  ]
}
