variable "global_policies" {
  type = list(object({
    name = string
    status = optional(string, "ACTIVE")
    description = optional(string)
    priority = number
    groups_included = list(string)
  }))
  default = []
}

variable "global_rules" {
  type = list(object({
    policy_name = string
    name = string
    status = optional(string, "ACTIVE")
    priority = number
    access = optional(string, "ALLOW")
    network_connection = optional(string, "ANYWHERE")
    network_includes = optional(list(string))
    network_excludes = optional(list(string))
    mfa_required = optional(bool, false)
    mfa_prompt = optional(string)
    session_idle = optional(number)
    session_lifetime = optional(number)
    primary_factor = optional(list(string))
  }))
  default = []
}

variable "app_policies" {
  type = list(object({
    name = string
    description = optional(string)
  }))
  default = []
}

variable "app_rules" {
  type = list(object({
    policy_name = string
    name = string
    status = optional(string, "ACTIVE")
    priority = number
    access = optional(string, "ALLOW")
  }))
  default = []
}
