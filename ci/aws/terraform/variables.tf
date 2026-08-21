variable "aws_region" { type = string; default = "us-east-1" }
variable "project_name" { type = string; default = "okta-terraform" }
variable "github_owner" { type = string }
variable "github_repo" { type = string }
variable "github_branch" { type = string; default = "main" }
variable "codestar_connection_arn" { type = string }
variable "terraform_state_bucket" { type = string }
variable "terraform_lock_table" { type = string; default = "terraform-locks" }
variable "slack_webhook_secret_arn" { type = string }
variable "okta_credentials_secret_arn" { type = string }
variable "enable_apply_stage" { type = bool; default = true }
variable "tags" { type = map(string); default = {} }
