terraform {
  required_version = ">= 1.5.0"

  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 6.15"
    }
  }

  # Backend is configured at init time via -backend-config
  # See backend.hcl.example in this directory.
  backend "s3" {}
  # For GCS, change to: backend "gcs" {}
}
