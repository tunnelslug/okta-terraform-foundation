variable "hooks" {
  description = "Event hooks to register"
  type = list(object({
    name       = string
    uri        = string
    events     = list(string)
    status     = optional(string, "ACTIVE")
    auth_type  = optional(string)
    auth_key   = optional(string, "Authorization")
    auth_value = optional(string)
    headers    = optional(map(string), {})
  }))
  default = []
}

variable "log_streams" {
  description = "Optional System Log streams (EventBridge or Splunk Cloud)"
  type = list(object({
    name              = string
    type              = string
    status            = optional(string, "ACTIVE")
    account_id        = optional(string)
    region            = optional(string)
    event_source_name = optional(string)
    host              = optional(string)
    edition           = optional(string)
    token             = optional(string)
  }))
  default = []
}
