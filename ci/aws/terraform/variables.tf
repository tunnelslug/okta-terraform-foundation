variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Prefix for CodePipeline / CodeBuild resources"
  default     = "okta-terraform"
}

variable "github_owner" {
  type        = string
  description = "GitHub org or user"
}

variable "github_repo" {
  type        = string
  description = "Repository name"
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "codestar_connection_arn" {
  type        = string
  description = "AWS CodeStar Connections ARN for GitHub"
}

variable "artifacts_bucket_name" {
  type        = string
  description = "S3 bucket for pipeline artifacts (created if create_artifacts_bucket=true)"
  default     = ""
}

variable "create_artifacts_bucket" {
  type    = bool
  default = true
}

variable "terraform_state_bucket" {
  type        = string
  description = "Existing S3 bucket holding Okta stack state (for IAM read/write)"
}

variable "terraform_lock_table" {
  type        = string
  description = "DynamoDB table for Terraform state locking"
  default     = "terraform-locks"
}

variable "slack_webhook_secret_arn" {
  type        = string
  description = "Secrets Manager ARN whose secret string is the Slack incoming webhook URL (or JSON with key webhook_url)"
}

variable "okta_credentials_secret_arn" {
  type        = string
  description = "Secrets Manager ARN with JSON: org_name, base_url, client_id, private_key, private_key_id"
}

variable "terraform_version" {
  type    = string
  default = "1.9.8"
}

variable "enable_apply_stage" {
  type        = bool
  description = "If true, pipeline includes ManualApproval + Apply after Plan"
  default     = true
}

variable "plan_on_module_change" {
  type        = bool
  description = "Re-plan all stacks in default_env when modules/ changes"
  default     = false
}

variable "default_env" {
  type    = string
  default = "dev"
}

variable "tags" {
  type    = map(string)
  default = {}
}
