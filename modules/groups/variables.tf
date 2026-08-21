variable "groups" {
  description = "List of groups to create"
  type = list(object({
    name                      = string
    description               = optional(string)
    custom_profile_attributes = optional(string)
  }))
  default = []
}

variable "group_rules" {
  description = "List of group rules (dynamic membership)"
  type = list(object({
    name              = string
    status            = optional(string, "ACTIVE")
    group_assignments = list(string)
    expression_value  = string
    users_excluded    = optional(list(string))
  }))
  default = []
}
