locals {
  sku_name = "Standard_v2" #Sku with WAF is : WAF_v2
  sku_tier = "Standard_v2"
  capacity = {
    min = 1 #Minimum capacity for autoscaling. Accepted values are in the range 0 to 100.
    max = 3 #Maximum capacity for autoscaling. Accepted values are in the range 2 to 125.
  }
  zones = ["1", "2", "3"] #Availability zones to spread the Application Gateway over. They are also only supported for v2 SKUs.

  # Backend Address Pool vars
  app_service_fqdn          = "${var.namespace}.azurewebsites.net"
  private_link_fqdn         = "${var.namespace}.privatelink.azurewebsites.net"
  backend_address_pool_name = "${var.namespace}-pool1"

  # subresource ames that get reused multiple times
  # These strings are just short versions of what they do. They aren't "magic strings" that must be these values
  frontend_port_name             = "${var.namespace}-feport"
  frontend_ip_configuration_name = "${var.namespace}-feip-public"
  http_setting_name              = "${var.namespace}-be-htst"
  listener_name_https            = "${var.namespace}-httplstn-https"
  listener_name_http             = "${var.namespace}-httplstn-http"
  request_routing_rule_name      = "${var.namespace}-rqrt"
  redirect_configuration_name    = "${var.namespace}-rdrcfg"
}

resource "azurerm_application_gateway" "agw" {
  name                = "${var.namespace}-hub-agw1"
  location            = var.location
  resource_group_name = var.resource_group_name
  enable_http2        = true
  zones               = local.zones
  tags                = var.tags

  sku {
    name = local.sku_name
    tier = local.sku_tier
  }

  autoscale_configuration {
    min_capacity = local.capacity.min
    max_capacity = local.capacity.max
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  gateway_ip_configuration {
    name      = "${var.namespace}-hub-agw1-ip-configuration"
    subnet_id = var.subnet_id
  }

  ## Frontend/Listener Config
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = var.public_ip_id
  }

  frontend_port {
    name = "${local.frontend_port_name}-80"
    port = 80
  }

  frontend_port {
    name = "${local.frontend_port_name}-443"
    port = 443
  }

  ssl_certificate {
    name                = var.cert_name
    key_vault_secret_id = "https://${var.key_vault_name}.vault.azure.net/secrets/${var.cert_name}"
  }

  http_listener {
    name                           = local.listener_name_http
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "${local.frontend_port_name}-80"
    protocol                       = "Http"
  }

  http_listener {
    name                           = local.listener_name_https
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "${local.frontend_port_name}-443"
    protocol                       = "Https"
    ssl_certificate_name           = var.cert_name
  }

  ## Backend Config
  backend_address_pool {
    name  = local.backend_address_pool_name
    fqdns = [local.private_link_fqdn]
  }

  backend_http_settings {
    # The app service requires the app gateway to communicate with the backend via https
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    host_name             = local.app_service_fqdn
    request_timeout       = 30
  }
  probe {
    name = "${var.namespace}-http-healthcheck"
    # See docs for why we use the domain name for the probe
    # https://learn.microsoft.com/en-us/azure/application-gateway/configure-web-app?tabs=customdomain%2Cazure-portal#edit-http-settings-for-app-service
    host                = var.domain_name
    interval            = 30
    path                = "/healthcheck"
    protocol            = "Http"
    timeout             = 30
    unhealthy_threshold = 3
  }

  ## Routing Config between the frontend listeners and the backends
  request_routing_rule {
    name                        = "${local.request_routing_rule_name}-http"
    rule_type                   = "Basic"
    http_listener_name          = local.listener_name_http
    redirect_configuration_name = local.redirect_configuration_name
    # Starting priority at not-1 so that if we have later higher priority rules we don't have to renumber everything
    priority = 100
  }

  request_routing_rule {
    name                       = "${local.request_routing_rule_name}-https"
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_https
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 101
  }

  redirect_configuration {
    name                 = local.redirect_configuration_name
    redirect_type        = "Permanent"
    include_path         = true
    include_query_string = true
    target_listener_name = local.listener_name_https
  }
}
