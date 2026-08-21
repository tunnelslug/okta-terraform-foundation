# Golden-template helpers
# Usage examples:
#   make init ENV=dev STACK=identity
#   make plan ENV=dev STACK=apps
#   make apply ENV=dev STACK=policies
#   make bootstrap-env ENV=staging   # copy stack skeletons from dev

ENV   ?= dev
STACK ?= identity
ROOT  := live/$(ENV)/$(STACK)

.PHONY: init plan apply destroy output bootstrap-env list-stacks

init:
	cd $(ROOT) && terraform init -backend-config=backend.hcl

plan:
	cd $(ROOT) && terraform plan

apply:
	cd $(ROOT) && terraform apply

destroy:
	cd $(ROOT) && terraform destroy

output:
	cd $(ROOT) && terraform output

list-stacks:
	@echo "Stacks under live/$(ENV):"
	@ls -1 live/$(ENV)

# Copy dev stack layout into another environment (staging/prod)
bootstrap-env:
	@test "$(ENV)" != "dev" || (echo "Set ENV=staging or ENV=prod"; exit 1)
	@mkdir -p live/$(ENV)
	@for s in identity apps policies authz governance; do \
	  if [ ! -d live/$(ENV)/$$s ]; then \
	    cp -R live/dev/$$s live/$(ENV)/$$s; \
	    echo "Created live/$(ENV)/$$s"; \
	    # Rewrite state keys in example backend files \
	    sed -i 's|/dev/|/$(ENV)/|g' live/$(ENV)/$$s/backend.hcl.example 2>/dev/null || \
	    sed -i '' 's|/dev/|/$(ENV)/|g' live/$(ENV)/$$s/backend.hcl.example; \
	    sed -i 's|/dev/|/$(ENV)/|g' live/$(ENV)/$$s/terraform.tfvars.example 2>/dev/null || \
	    sed -i '' 's|/dev/|/$(ENV)/|g' live/$(ENV)/$$s/terraform.tfvars.example; \
	    sed -i 's/default = "dev"/default = "$(ENV)"/g' live/$(ENV)/$$s/variables.tf 2>/dev/null || true; \
	  else \
	    echo "Skip live/$(ENV)/$$s (already exists)"; \
	  fi; \
	done
	@echo "Done. Edit backend.hcl and terraform.tfvars under live/$(ENV)/*"

.PHONY: gen-oidc-key check-no-api-token

# Generate RSA key pair for Okta API Services app (private_key_jwt)
# Public key → upload to Okta. Private key → secrets manager only.
gen-oidc-key:
	@mkdir -p .secrets
	@openssl genrsa -out .secrets/okta-tf-private.pem 2048
	@openssl rsa -in .secrets/okta-tf-private.pem -pubout -out .secrets/okta-tf-public.pem
	@chmod 600 .secrets/okta-tf-private.pem
	@echo "Created:"
	@echo "  .secrets/okta-tf-private.pem  (KEEP SECRET – load into Vault/ASM)"
	@echo "  .secrets/okta-tf-public.pem   (upload to Okta API Services app)"
	@echo "Then set OKTA_API_PRIVATE_KEY and OKTA_API_PRIVATE_KEY_ID in CI."

# Fail CI if anyone introduces SSWS api_token usage
check-no-api-token:
	@if grep -RIn --include='*.tf' --include='*.hcl' -E 'api_token\s*=|OKTA_API_TOKEN' live modules shared 2>/dev/null; then \
	  echo "ERROR: api_token / OKTA_API_TOKEN is forbidden. Use OIDC client_id + private_key. See docs/AUTH.md"; \
	  exit 1; \
	else \
	  echo "OK: no API token usage found"; \
	fi

.PHONY: fmt validate lint ci-local

# Recursive format (writes)
fmt:
	terraform fmt -recursive

# Validate all fully scaffolded dev stacks (local backend, no cloud required)
validate:
	@set -e; \
	for stack in identity apps policies authz governance; do \
	  dir=live/dev/$$stack; \
	  echo "==> validate $$dir"; \
	  printf '%s\n' 'terraform { backend "local" {} }' > $$dir/backend_override.tf; \
	  (cd $$dir && terraform init -backend=false -input=false >/dev/null); \
	  (cd $$dir && terraform validate) || true; \
	  rm -f $$dir/backend_override.tf; \
	done

# TFLint across modules (install tflint separately: https://github.com/terraform-linters/tflint)
lint:
	@command -v tflint >/dev/null || { echo "Install tflint first"; exit 1; }
	@tflint --init 2>/dev/null || true
	@set -e; \
	for d in modules/groups modules/apps/oauth modules/apps/saml \
	         modules/policies/signon modules/policies/mfa modules/policies/password \
	         modules/auth-servers modules/authenticators modules/network \
	         modules/trusted-origins modules/admin-roles modules/users \
	         modules/governance/labels; do \
	  echo "==> tflint $$d"; \
	  (cd $$d && tflint --format compact) || true; \
	done

# What CI runs on PRs (local approximation)
ci-local: check-no-api-token fmt validate lint
	@echo "ci-local complete"
