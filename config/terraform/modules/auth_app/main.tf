# Currently this Auth App module is only used by the cloudcity environment.
# We don't have permission to create Application Registration with terraform on WHO Azure

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
}

data "azuread_client_config" "current" {}

provider "azuread" {
  tenant_id = var.tenant_id #"4efe96cc-3e99-409d-8d0e-432bd2ad9fce"
}

resource "azuread_application" "app" {
  display_name = var.name
  # identifier_uris  = ["api://example-app"]
  # logo_image       = filebase64("/path/to/logo.png")
  # owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADandPersonalMicrosoftAccount"

  api {
    mapped_claims_enabled          = false
    requested_access_token_version = 2
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access ${var.name} on behalf of the signed-in user."
      admin_consent_display_name = "Access ${var.name}"
      enabled                    = true
      id                         = "96183846-204b-4b43-82e1-5d2222eb4b9b"
      type                       = "User"
      user_consent_description   = "Allow the application to access ${var.name} on your behalf."
      user_consent_display_name  = "Access ${var.name}"
      value                      = "user_impersonation"
    }
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    # resource_access {
    #   id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0" # email
    #   type = "Scope"
    # }
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read (profile and sign in)
      type = "Scope"
    }
  }
  web {
    homepage_url  = "https://${var.domain}"
    logout_url    = "https://${var.domain}/logout"
    redirect_uris = ["https://${var.domain}/.auth/login/aad/callback"]
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_application_password" "client_secret" {
  application_object_id = azuread_application.app.object_id
}
