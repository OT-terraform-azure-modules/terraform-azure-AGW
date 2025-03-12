data "azurerm_resource_group" "modular_rg" {
  name = var.resource_group_name
}

resource "azurerm_public_ip" "agw" {
  #count               = var.public_ip_enabled ? 1 : 0
  name                = "${var.resource_group_name}-agw-ip"
  location            = data.azurerm_resource_group.modular_rg.location
  resource_group_name = data.azurerm_resource_group.modular_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "app_gateway" {
  name                = var.app_gateway_name
  resource_group_name = data.azurerm_resource_group.modular_rg.name
  location            = data.azurerm_resource_group.modular_rg.location

  #sku                 = var.sku
  sku {
    name     = var.sku.name
    tier     = var.sku.tier
    capacity = var.sku.capacity
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  dynamic "frontend_port" {
    for_each = var.frontend_port
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  frontend_ip_configuration {
    name                 = azurerm_public_ip.agw.name
    public_ip_address_id = azurerm_public_ip.agw.id
  }

#dynamic "frontend_ip_configuration" {
#  for_each = var.listeners
#  content {
#    name                 = "frontend-ip-${frontend_ip_configuration.value.frontend_ip}"
#    public_ip_address_id = azurerm_public_ip.agw.id
#    #subnet_id            = var.subnet_id
#    #public_ip_address_id = frontend_ip_configuration.value.frontend_ip == "Public" ? var.public_ip_id : null
#    #subnet_id            = frontend_ip_configuration.value.frontend_ip == "Private" ? var.subnet_id : null
#  }
#}

  dynamic "backend_address_pool" {
    for_each = var.backend_pools
    content {
      name         = backend_address_pool.value.name
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_settings
    content {
      name                  = backend_http_settings.value.name
      cookie_based_affinity  = backend_http_settings.value.cookie_based_affinity
      port                  = backend_http_settings.value.port
      protocol              = backend_http_settings.value.protocol
      request_timeout       = backend_http_settings.value.request_timeout
    }
  }

  dynamic "http_listener" {
    for_each = var.listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.frontend_port_name
      #frontend_port_name             = frontend_port.value.name
      protocol                       = http_listener.value.protocol
      host_name                      = http_listener.value.host_name
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.routing_rules
    content {
      name                       = request_routing_rule.value.name
      priority                   = request_routing_rule.value.priority
      rule_type                  = request_routing_rule.value.rule_type
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
    }
  }

  dynamic "probe" {
    for_each = var.health_probes
    content {
      name                = probe.value.name
      protocol            = probe.value.protocol
      path                = probe.value.path
      interval            = probe.value.interval
      timeout             = probe.value.timeout
      unhealthy_threshold = probe.value.unhealthy_threshold
      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
    }
  }
}