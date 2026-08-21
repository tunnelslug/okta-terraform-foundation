# STACK: apps
# Reads group IDs from identity remote state

data "terraform_remote_state" "identity" {
  backend = "s3"
  config = {
    bucket = "YOUR_COMPANY-terraform-state"
    key    = "okta/dev/identity/terraform.tfstate"
    region = "us-east-1"
  }
}

module "oauth_apps" {
  source = "../../../modules/apps/oauth"
  apps = [
    {
      label         = "Internal-Dashboard"
      type          = "web"
      grant_types   = ["authorization_code", "refresh_token"]
      redirect_uris = ["https://dashboard.example.com/callback"]
      response_types = ["code"]
      group_ids = [
        data.terraform_remote_state.identity.outputs.group_ids["Engineering"]
      ]
    },
  ]
}
