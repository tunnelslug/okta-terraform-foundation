variable "okta_org_name" {
  type        = string
  description = "Okta org name (subdomain)"
}

variable "okta_base_url" {
  type        = string
  description = "okta.com | oktapreview.com | okta-emea.com"
  default     = "okta.com"
}

variable "okta_client_id" {
  type        = string
  description = "OAuth 2.0 Client ID of the Terraform service application"
  sensitive   = true
}

variable "okta_private_key" {
  type        = string
  description = "PEM-encoded private key for the Terraform service application"
  sensitive   = true
}

variable "okta_private_key_id" {
  type        = string
  description = "Key ID (kid) of the private key"
}

variable "okta_scopes" {
  type        = list(string)
  description = "OAuth scopes granted to this stack's service principal"
  default     = []
}

variable "environment" {
  type        = string
  description = "Environment name (dev | staging | prod)"
}
