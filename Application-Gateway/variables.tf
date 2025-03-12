variable "app_gateway_name" {}
variable "resource_group_name" {}
variable "location" {}
#variable "sku_name" {}
#variable "sku_tier" {}
variable "sku" {
  description = "The SKU tier of the Application Gateway."
  type = object({
    name     = string
    tier     = string
    capacity = optional(number)
  })
}

variable "frontend_port" {
  description = "The Frontend port of the Application Gateway."
  type = list(object({
    name     = string
    port     = number
  }))
}

variable "subnet_id" {}

variable "backend_pools" { 
  description = "The Backend pools of the Application Gateway."
  type = list(object({
    name = string
    ip_addresses = list(string)
  })) 
}

variable "backend_settings" { 
  description = "The Backend settings of the Application Gateway."
  type = list(object({
    name = string
    cookie_based_affinity = string
    port = number
    protocol = string
    request_timeout = number
  })) 
}

variable "listeners" {
  description = "List of listeners with their configurations."
  type = list(object({
    name     = string
    frontend_ip_configuration_name = string
    frontend_port_name     = string 
    protocol = string
    host_name = optional(string)
    ssl_certificate_name = optional(string)
  }))
}

variable "ssl_certificates" {
  description = "List of SSL certificates with names and base64 pfx content."
  type = list(object({
    name    = string
    data    = string
    password = string
  }))
}

variable "routing_rules" { 
  description = "List of Routing rules."
  type = list(object({
    name = string
    priority = number
    rule_type = string
    http_listener_name = string
    backend_address_pool_name = string
    backend_http_settings_name = string
  })) 
}

variable "health_probes" { 
  type = list(object({
    name = string
    protocol = string
    path = string
    interval = number
    timeout = number
    unhealthy_threshold = number
    pick_host_name_from_backend_http_settings = bool
  })) 
}