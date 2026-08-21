variable "okta_org_name" { type = string }
variable "okta_base_url" { type = string; default = "oktapreview.com" }
variable "okta_client_id" { type = string; sensitive = true }
variable "okta_private_key" { type = string; sensitive = true }
variable "okta_private_key_id" { type = string }

variable "okta_scopes" {
  type = list(string)
  default = [
    "okta.authorizationServers.manage",
    "okta.authorizationServers.read",
    "okta.trustedOrigins.manage",
    "okta.groups.read",
    "okta.apps.read",
  ]
}

variable "environment" {
  type    = string
  default = "staging"
}

variable "identity_state_bucket" { type = string }
variable "identity_state_key" {
  type    = string
  default = "okta/dev/identity/terraform.tfstate"
}
variable "identity_state_region" {
  type    = string
  default = "us-east-1"
}

variable "apps_state_bucket" {
  type    = string
  default = null
}
variable "apps_state_key" {
  type    = string
  default = "okta/dev/apps/terraform.tfstate"
}
variable "apps_state_region" {
  type    = string
  default = "us-east-1"
}
