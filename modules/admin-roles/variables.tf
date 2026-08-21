variable "resource_sets" {
  description = "Custom Resource Sets for admin role scoping"
  type = list(object({
    label         = string
    description   = optional(string)
    resources     = optional(list(string))
    resources_orn = optional(list(string))
  }))
  default = []
}

variable "custom_roles" {
  description = "Custom Admin Roles"
  type = list(object({
    label       = string
    description = optional(string)
    permissions = list(string)
  }))
  default = []
}

variable "assignments" {
  description = "Assignments of custom roles to members within a resource set"
  type = list(object({
    role_label         = string
    resource_set_label = string
    members            = list(string)
  }))
  default = []
}
