variable "users" {
  description = "Users to manage (use sparingly)"
  type = list(object({
    first_name                = string
    last_name                 = string
    login                     = string
    email                     = string
    status                    = optional(string, "ACTIVE")
    password                  = optional(string)
    custom_profile_attributes = optional(string)
    expire_password_on_create = optional(bool, false)
    skip_roles                = optional(bool, true)
    group_ids                 = optional(list(string))
  }))
  default = []
}
