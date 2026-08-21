variable "auth_servers" {
  type = list(object({
    name = string
    description = optional(string)
    audiences = list(string)
    issuer_mode = optional(string, "ORG_URL")
    status = optional(string, "ACTIVE")
  }))
  default = []
}

variable "scopes" {
  type = list(object({
    auth_server_name = string
    name = string
    description = optional(string)
    consent = optional(string, "IMPLICIT")
    default = optional(bool, false)
    metadata_publish = optional(string, "ALL_CLIENTS")
    display_name = optional(string)
  }))
  default = []
}

variable "claims" {
  type = list(object({
    auth_server_name = string
    name = string
    status = optional(string, "ACTIVE")
    value_type = string
    value = optional(string)
    claim_type = optional(string, "RESOURCE")
    always_include_in_token = optional(bool, false)
    group_filter_type = optional(string)
    scopes = optional(list(string))
  }))
  default = []
}

variable "policies" {
  type = list(object({
    auth_server_name = string
    name = string
    description = optional(string)
    priority = number
    client_whitelist = list(string)
    status = optional(string, "ACTIVE")
  }))
  default = []
}

variable "rules" {
  type = list(object({
    auth_server_name = string
    policy_name = string
    name = string
    status = optional(string, "ACTIVE")
    priority = number
    grant_type_whitelist = list(string)
    scope_whitelist = optional(list(string), ["*"])
    group_whitelist = optional(list(string))
    group_blacklist = optional(list(string))
    user_whitelist = optional(list(string))
    user_blacklist = optional(list(string))
    inline_hook_id = optional(string)
  }))
  default = []
}
