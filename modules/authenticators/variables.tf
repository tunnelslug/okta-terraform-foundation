variable "authenticators" {
  description = "Authenticators to configure"
  type = list(object({
    name               = string
    key                = string
    status             = optional(string, "ACTIVE")
    settings           = optional(string)
    provider_json      = optional(string)
    agree_to_terms     = optional(bool)
    legacy_ignore_name = optional(bool)
  }))
  default = []
}
