# Adopting this template at a new company

## 1. Copy the template

```bash
git clone <this-repo> okta-terraform-<company>
cd okta-terraform-<company>
```

## 2. Remote state backend

### AWS (S3 + DynamoDB)

```bash
# Example – adjust names/regions
aws s3 mb s3://acme-terraform-state
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### GCP (GCS)

```bash
gsutil mb -l us-central1 gs://acme-terraform-state
# Enable object versioning for state history
gsutil versioning set on gs://acme-terraform-state
```

## 3. Okta OIDC / API Services app(s) — no API tokens

**Do not create or use SSWS API tokens.** Use an OAuth 2.0 API Services application with private_key_jwt.

1. Create an **API Services** app in Okta (Applications → Create App Integration → API Services).
2. Generate a key pair (`make gen-oidc-key`) and upload the **public** key; store the private key in a secrets manager.
3. Note **Client ID** and **Key ID (kid)**.
4. Grant **only** the scopes needed per stack (see `docs/AUTH.md` and `docs/OWNERSHIP.md`).
5. Optionally create **one API Services app per stack** for least privilege.
6. Full walkthrough: [docs/AUTH.md](AUTH.md).

## 4. Bootstrap dev

```bash
cd live/dev/identity
cp backend.hcl.example backend.hcl          # set real bucket/key
cp terraform.tfvars.example terraform.tfvars
export OKTA_PRIVATE_KEY="$(cat ~/secrets/okta-tf.pem)"
terraform init -backend-config=backend.hcl
terraform apply
```

Then `policies` → `apps` → `authz` → `governance`.

## 5. Staging / prod

```bash
make bootstrap-env ENV=staging
make bootstrap-env ENV=prod
# Edit backends and tfvars for each env
```

## 6. CODEOWNERS (GitHub example)

```
# .github/CODEOWNERS
/live/*/identity/**    @identity-platform
/live/*/apps/**        @app-iam-team
/live/*/policies/**    @security-iam
/live/*/authz/**       @platform-security
/live/*/governance/**  @governance-team
/modules/**            @identity-platform
```

## 7. CI pattern

Run plan/apply **per stack directory**, not on the whole repo:

```yaml
# Pseudocode
on: pull_request
jobs:
  plan:
    strategy:
      matrix:
        stack: [identity, apps, policies, authz, governance]
    steps:
      - run: cd live/${{ env.ENVIRONMENT }}/${{ matrix.stack }} && terraform plan
```

Atlantis, Spacelift, Env0, and Terraform Cloud all support per-directory workspaces — map each `live/<env>/<stack>` to a workspace.
