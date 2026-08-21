variable "policies" {
  type = list(object({
    name            = string
    status          = optional(string, "ACTIVE")
    description     = optional(string)
    priority        = number
    groups_included = list(string)
    password_min_length = optional(number, 12)
    password_min_lowercase = optional(number, 1)
    password_min_uppercase = optional(number, 1)
    password_min_number = optional(number, 1)
    password_min_symbol = optional(number, 0)
    password_exclude_username = optional(bool, true)
    password_history_count = optional(number, 4)
    password_max_age_days = optional(number, 90)
    password_min_age_minutes = optional(number, 0)
    password_expire_warn_days = optional(number, 5)
  }))
  default = []
}

variable "rules" {
  type = list(object({
    policy_name = string
    name        = string
    status      = optional(string, "ACTIVE")
    priority    = number
  }))
  default = []
}
