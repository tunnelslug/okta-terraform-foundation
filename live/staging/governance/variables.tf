variable "okta_org_name" { type = string }
variable "okta_base_url" { type = string; default = "oktapreview.com" }
variable "okta_client_id" { type = string; sensitive = true }
variable "okta_private_key" { type = string; sensitive = true }
variable "okta_private_key_id" { type = string }

variable "okta_scopes" {
  type = list(string)
  default = [
    "okta.governance.labels.manage",
    "okta.governance.labels.read",
    "okta.roles.manage",
    "okta.roles.read",
    "okta.eventHooks.manage",
    "okta.eventHooks.read",
    "okta.logStreams.manage",
    "okta.logStreams.read",
  ]
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "event_hook_uri" {
  type        = string
  description = "HTTPS endpoint for app lifecycle event hook (empty = do not create hook)"
  default     = ""
}

variable "event_hook_auth_type" {
  type    = string
  default = null
}

variable "event_hook_auth_key" {
  type    = string
  default = "Authorization"
}

variable "event_hook_auth_value" {
  type      = string
  default   = null
  sensitive = true
}

variable "log_streams" {
  description = "Optional okta_log_stream definitions (EventBridge / Splunk)"
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
