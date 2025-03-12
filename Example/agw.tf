data "azurerm_resource_group" "modular_rg" {
  name = var.resource_group_name
}

module "app_gateway" {
  source              = "../Application-Gateway"
  resource_group_name = data.azurerm_resource_group.modular_rg.name
  location            = data.azurerm_resource_group.modular_rg.location
  subnet_id           = var.subnet_id
  
  app_gateway_name = var.app_gateway_name
  sku              = var.sku
  frontend_port    = var.frontend_port
  #sku_name                 = var.sku_name
  #sku_tier                 = var.sku_tier
  #capacity                 = var.capacity

  backend_pools  = var.backend_pools
  backend_settings = var.backend_settings
  
  ssl_certificates = var.ssl_certificates
  listeners        = var.listeners
  routing_rules    = var.routing_rules
  health_probes    = var.health_probes
}