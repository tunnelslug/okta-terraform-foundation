variable "okta_org_name" { type = string }
variable "okta_base_url" { type = string; default = "oktapreview.com" }
variable "okta_client_id" { type = string; sensitive = true }
variable "okta_private_key" { type = string; sensitive = true }
variable "okta_private_key_id" { type = string }

variable "okta_scopes" {
  type = list(string)
  default = [
    "okta.apps.manage",
    "okta.apps.read",
    "okta.groups.read",
  ]
}

variable "environment" {
  type    = string
  default = "prod"
}

# Remote state config for the identity stack
variable "identity_state_bucket" {
  type        = string
  description = "S3/GCS bucket holding the identity stack state"
}

variable "identity_state_key" {
  type        = string
  description = "State key/prefix for identity stack"
  default     = "okta/dev/identity/terraform.tfstate"
}

variable "identity_state_region" {
  type    = string
  default = "us-east-1"
}

# Optional: policies stack (for authentication_policy_id)
variable "policies_state_bucket" {
  type    = string
  default = null
}

variable "policies_state_key" {
  type    = string
  default = "okta/dev/policies/terraform.tfstate"
}

variable "policies_state_region" {
  type    = string
  default = "us-east-1"
}
