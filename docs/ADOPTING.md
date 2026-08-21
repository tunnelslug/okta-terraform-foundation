# Adopting this template at a new company

## 1. Copy the template

```bash
git clone <this-repo> okta-terraform-<company>
cd okta-terraform-<company>
```

## 2. Remote state backend

### AWS (S3 + DynamoDB)

```bash
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
gsutil versioning set on gs://acme-terraform-state
```

## 3. Okta OIDC / API Services app(s) — no API tokens

**Do not create or use SSWS API tokens.** Use an OAuth 2.0 API Services application with private_key_jwt.

1. Create an **API Services** app in Okta.
2. Generate a key pair (`make gen-oidc-key`) and upload the **public** key; store the private key in a secrets manager.
3. Note **Client ID** and **Key ID (kid)**.
4. Grant **only** the scopes needed per stack (see `docs/AUTH.md` and `docs/OWNERSHIP.md`).
5. Optionally create **one API Services app per stack** for least privilege.

## 4. Bootstrap dev

```bash
cd live/dev/identity
cp backend.hcl.example backend.hcl
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
```

## 6. CODEOWNERS and CI

Map each `live/<env>/<stack>` to a team and run plan/apply per stack directory.
