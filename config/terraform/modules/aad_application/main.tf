terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
}

provider "azuread" {
  tenant_id = var.tenant_id #"4efe96cc-3e99-409d-8d0e-432bd2ad9fce"
}

data "azuread_client_config" "current" {}

resource "azuread_application" "app" {
  display_name = var.name
  # identifier_uris  = ["api://example-app"]
  # logo_image       = filebase64("/path/to/logo.png")
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  api {
    mapped_claims_enabled          = false
    requested_access_token_version = 2
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0" # email
      type = "Scope"
    }
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
