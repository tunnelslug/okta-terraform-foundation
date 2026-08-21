data "terraform_remote_state" "identity" {
  backend = "s3"
  config = {
    bucket = var.identity_state_bucket
    key    = var.identity_state_key
    region = var.identity_state_region
  }
}

locals {
  group_ids = data.terraform_remote_state.identity.outputs.group_ids
}
