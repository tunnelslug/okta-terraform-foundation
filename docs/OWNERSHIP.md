# Ownership & Split-State Model

This template is designed so **multiple teams can safely co-own one Okta org** without stepping on each other.

## Why split state?

A single monolithic Terraform state for an entire Okta org creates:

| Problem | Impact |
|---------|--------|
| Blast radius | One bad `apply` can affect every group, app, and policy |
| Lock contention | Teams queue on the same state lock |
| Permission sprawl | Everyone needs broad admin rights to run Terraform |
| Review friction | PRs mix unrelated changes (groups + apps + policies) |
| Ownership blur | No clear "who owns this resource?" |

**Split state** gives each ownership domain its own state file, backend, and (optionally) its own service principal with least-privilege scopes.

## Ownership domains (stacks)

| Stack | Owns | Typical team | Suggested scopes |
|-------|------|--------------|------------------|
| **identity** | Groups, group rules, users (break-glass), authenticators, network zones | Identity / IAM platform | `okta.groups.*`, `okta.users.*`, `okta.authenticators.*`, `okta.networkZones.*` |
| **apps** | OAuth/OIDC apps, SAML apps, app group assignments | App / product teams or IAM | `okta.apps.*` |
| **policies** | Global session, app sign-on, MFA enrollment, password policies | Security / IAM | `okta.policies.*`, `okta.groups.read` |
| **authz** | Custom authorization servers, scopes, claims, trusted origins | API / platform security | `okta.authorizationServers.*`, `okta.trustedOrigins.*` |
| **governance** | Governance labels, custom admin roles, resource sets | Governance / GRC / IAM | `okta.governance.labels.*`, `okta.roles.*` |

You can merge or further split stacks to match your org chart. The pattern scales.

## How stacks talk to each other

Downstream stacks read upstream outputs via `terraform_remote_state`:

```hcl
# live/dev/apps/data.tf
data "terraform_remote_state" "identity" {
  backend = "s3"   # or "gcs"
  config = {
    bucket = "your-company-terraform-state"
    key    = "okta/dev/identity/terraform.tfstate"
    region = "us-east-1"
  }
}

# Then use:
# data.terraform_remote_state.identity.outputs.group_ids["Engineering"]
```

**Rule of thumb:** only read remote state; never write across stack boundaries.

## Recommended apply order

```
1. identity
2. policies      (needs group IDs)
3. apps          (needs group IDs + policy IDs)
4. authz         (needs group IDs + client IDs)
5. governance    (mostly independent; labels can be early)
```

Automate with a simple pipeline that applies stacks in order, or let each team own its pipeline.

## Backend isolation

Each `live/<env>/<stack>/` directory has its **own** backend key/prefix:

```
s3://bucket/okta/dev/identity/terraform.tfstate
s3://bucket/okta/dev/apps/terraform.tfstate
s3://bucket/okta/prod/identity/terraform.tfstate
...
```

IAM / GCS IAM should grant each team write access only to their stack prefix.

## Service principal isolation (optional but recommended)

Create **one OAuth service app per stack** (or per team) with only the scopes that stack needs. Store credentials in a secrets manager; inject via CI.

## Adopting at a new company

1. Fork / copy this template.
2. Fill in `shared/backend-*.hcl.example` → real backend configs.
3. Set org name, create Terraform service app(s), grant scopes.
4. Start with `live/dev/identity`, then layer other stacks.
5. Map stacks to GitHub CODEOWNERS / GitLab CODEOWNERS so PRs route correctly.
