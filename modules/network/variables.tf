variable "zones" {
  description = "Network Zones"
  type = list(object({
    name                          = string
    type                          = string
    status                        = optional(string, "ACTIVE")
    usage                         = optional(string, "POLICY")
    asns                          = optional(list(string))
    gateways                      = optional(list(string))
    proxies                       = optional(list(string))
    locations                     = optional(list(string))
    dynamic_locations             = optional(list(string))
    dynamic_proxy_type            = optional(string)
    ip_service_categories_include = optional(list(string))
    ip_service_categories_exclude = optional(list(string))
  }))
  default = []
}
