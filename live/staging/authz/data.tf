data "terraform_remote_state" "identity" {
  backend = "s3"
  config = {
    bucket = var.identity_state_bucket
    key    = var.identity_state_key
    region = var.identity_state_region
  }
}

data "terraform_remote_state" "apps" {
  count   = var.apps_state_bucket != null ? 1 : 0
  backend = "s3"
  config = {
    bucket = var.apps_state_bucket
    key    = var.apps_state_key
    region = var.apps_state_region
  }
}

locals {
  group_ids  = data.terraform_remote_state.identity.outputs.group_ids
  client_ids = try(data.terraform_remote_state.apps[0].outputs.oauth_client_ids, {})
}
