# IMPORTANT NOTE
# CREATING THE POOL
# This module sets up the scale set(s) and networking for the
# ci agents that live in the private networks to deploy to prod
# and access the ACR.

# However, it does not actually make the Azure DevOps pool, because
# that is not well supported by Terraform at this time.

# You must create the pool manually in the ui in the project settings at
# dev.azure.com, by creating a new agent pool and pointing it to the
# appropriate scale set.

# DELETING A POOL
# In order to delete a ci agent pool, the pool must be deleted
# at the organization level. Deleting it from the project level merely
# removes it from the project but does not delete it. This may require help
# from WHO if we do not have access at the org level.

# Also, the pool must be deleted before deleting the scale set.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.24.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 0.2.0"
    }
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "scaleset" {
  name                = "${var.namespace}-ci-agent-set"
  resource_group_name = var.resource_group_name
  location            = var.location
  # This is probably too big of a vm, but B1ls didn't have enough tmp disk to install the az cli. A1v2 might work too
  sku = "Standard_F2"

  instances      = 1
  admin_username = "adminuser"
  overprovision  = false
  upgrade_mode   = "Manual"
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags and instances because the Azure DevOps Agent Pool manages them
      tags,
      instances
    ]
  }
  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ci_agent_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "${var.namespace}-scale-set-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id
    }
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "install-ci-agent" {
  name                         = "install-ci-agent"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.scaleset.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"
  protected_settings = jsonencode({
    "script" = filebase64("../../ci_agent_scripts/install-az-cli.sh")
  })
  depends_on = [
    azurerm_linux_virtual_machine_scale_set.scaleset
  ]
}
