# Managed service identity
resource "azurerm_user_assigned_identity" "prod" {
  location            = var.location
  resource_group_name = var.prod_resource_group_name
  name                = "${var.namespace}-hub-agw1-msi"
}

# Managed service identity
resource "azurerm_user_assigned_identity" "test" {
  location            = var.location
  resource_group_name = var.test_resource_group_name
  name                = "${var.namespace}-uat-hub-agw1-msi"
}
# Key Vault
resource "azurerm_key_vault" "agw" {
  count                    = var.create_key_vault ? 1 : 0
  name                     = "${var.namespace}kv"
  location                 = var.location
  resource_group_name      = var.prod_resource_group_name
  tenant_id                = var.tenant_id
  purge_protection_enabled = false
  sku_name                 = "standard"

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = [for ip in values(var.key_vault_developer_ips) : "${ip}/32"]
    virtual_network_subnet_ids = [var.subnet_id]
  }
}


resource "azurerm_key_vault_access_policy" "developers" {
  count        = var.create_key_vault ? 1 : 0
  key_vault_id = azurerm_key_vault.agw[0].id
  tenant_id    = var.tenant_id
  object_id    = var.object_id

  certificate_permissions = [
    "Create",
    "Get",
    "List",
    "Delete",
    "Purge"
  ]
}

resource "azurerm_key_vault_access_policy" "prod" {
  count        = var.create_key_vault ? 1 : 0
  key_vault_id = azurerm_key_vault.agw[0].id
  tenant_id    = var.tenant_id
  object_id    = azurerm_user_assigned_identity.prod.principal_id

  secret_permissions = [
    "Get"
  ]
}

resource "azurerm_key_vault_access_policy" "test" {
  count        = var.create_key_vault ? 1 : 0
  key_vault_id = azurerm_key_vault.agw[0].id
  tenant_id    = var.tenant_id
  object_id    = azurerm_user_assigned_identity.prod.principal_id

  secret_permissions = [
    "Get"
  ]
}

resource "azurerm_key_vault_certificate" "cert" {
  count        = var.create_key_vault ? 1 : 0
  name         = var.namespace
  key_vault_id = azurerm_key_vault.agw[0].id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = var.subject_alt_names
      }

      subject            = "CN=${var.domain_name}"
      validity_in_months = 12
    }
  }
  depends_on = [
    azurerm_key_vault_access_policy.developers,
    azurerm_key_vault_access_policy.prod,
    azurerm_key_vault_access_policy.test,
  ]
}

resource "time_sleep" "wait_60_seconds" {
  count           = var.create_key_vault ? 1 : 0
  depends_on      = [azurerm_key_vault_certificate.cert]
  create_duration = "60s"
}
