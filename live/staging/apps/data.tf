############################################################
# Cross-stack references (read-only)
############################################################

data "terraform_remote_state" "identity" {
  backend = "s3"
  config = {
    bucket = var.identity_state_bucket
    key    = var.identity_state_key
    region = var.identity_state_region
  }
}

# Optional – only if policies stack has been applied
data "terraform_remote_state" "policies" {
  count   = var.policies_state_bucket != null ? 1 : 0
  backend = "s3"
  config = {
    bucket = var.policies_state_bucket
    key    = var.policies_state_key
    region = var.policies_state_region
  }
}

locals {
  group_ids = data.terraform_remote_state.identity.outputs.group_ids

  # Safe lookup when policies stack may not exist yet
  app_signon_policy_ids = try(
    data.terraform_remote_state.policies[0].outputs.app_signon_policy_ids,
    {}
  )
}
