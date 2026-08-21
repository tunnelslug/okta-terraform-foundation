# Importing existing Okta resources

1. Inventory objects in Okta (IDs + names)
2. Declare matching HCL in the owning stack
3. `terraform import 'module.groups.okta_group.this["Engineering"]' <group_id>`
4. `terraform plan` until clean

Import does not change Okta — it only binds state.

Common addresses:

- `module.groups.okta_group.this["Name"]`
- `module.groups.okta_group_rule.this["RuleName"]`
- `module.oauth_apps.okta_app_oauth.this["Label"]`

See the full resource ID table in the project docs. Prefer the strangler pattern: import stack-by-stack.
