# Minimal working example – creates one group and one OIDC app

terraform {
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 6.15"
    }
  }
}

provider "okta" {
  # Credentials via environment variables
}

resource "okta_group" "example" {
  name        = "Terraform-Example-Group"
  description = "Created by the minimal example"
}

resource "okta_app_oauth" "example" {
  label          = "Terraform-Example-App"
  type           = "web"
  grant_types    = ["authorization_code"]
  redirect_uris  = ["https://example.com/callback"]
  response_types = ["code"]
}
