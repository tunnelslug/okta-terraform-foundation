############################################################
# STACK: governance
# Owner: Governance / GRC / IAM
# State: isolated (okta/<env>/governance/terraform.tfstate)
#
# Owns: OIG labels, custom admin roles, resource sets,
#       event hooks / log streams (e.g. app lifecycle tracking)
# Mostly independent – can be applied early or late
############################################################

module "labels" {
  source = "../../../modules/governance/labels"

  labels = [
    {
      name = "Compliance"
      values = [
        { name = "SOX" },
        { name = "PII" },
        { name = "PCI" },
        { name = "HIPAA" },
      ]
    },
    {
      name = "DataClassification"
      values = [
        { name = "Public" },
        { name = "Internal" },
        { name = "Confidential" },
        { name = "Restricted" },
      ]
    },
    {
      name = "BusinessCriticality"
      values = [
        { name = "Low" },
        { name = "Medium" },
        { name = "High" },
        { name = "Critical" },
      ]
    },
    {
      name = "Environment"
      values = [
        { name = "Dev" },
        { name = "Staging" },
        { name = "Production" },
      ]
    },
  ]
}

module "admin_roles" {
  source = "../../../modules/admin-roles"

  resource_sets = [
    {
      label       = "Engineering-Apps-and-Groups"
      description = "Scoped to engineering apps and groups"
      resources   = []
    },
  ]

  custom_roles = [
    {
      label       = "App-Admin-Limited"
      description = "Can manage applications but not users or policies"
      permissions = [
        "okta.apps.manage",
        "okta.apps.read",
        "okta.groups.read",
      ]
    },
  ]

  assignments = []
}

############################################################
# Track application create / update / delete (and related)
# via Okta Event Hook → your HTTP endpoint (Lambda, SIEM, etc.)
#
# Set event_hook_uri in tfvars (or leave empty to skip).
# Verify the hook in Okta Admin after first apply.
############################################################

module "event_hooks" {
  source = "../../../modules/event-hooks"

  hooks = var.event_hook_uri != "" ? [
    {
      name = "app-lifecycle-tracker"
      uri  = var.event_hook_uri
      events = [
        "application.lifecycle.create",
        "application.lifecycle.update",
        "application.lifecycle.delete",
        "application.lifecycle.activate",
        "application.lifecycle.deactivate",
      ]
      status     = "ACTIVE"
      auth_type  = var.event_hook_auth_type
      auth_key   = var.event_hook_auth_key
      auth_value = var.event_hook_auth_value
    },
  ] : []

  # Optional full System Log stream (EventBridge / Splunk) — configure via tfvars
  log_streams = var.log_streams
}
