# Golden-template helpers
# Usage examples:
#   make init ENV=dev STACK=identity
#   make plan ENV=dev STACK=apps
#   make apply ENV=dev STACK=policies
#   make bootstrap-env ENV=staging

ENV   ?= dev
STACK ?= identity
ROOT  := live/$(ENV)/$(STACK)

.PHONY: init plan apply destroy output bootstrap-env list-stacks fmt validate lint ci-local gen-oidc-key check-no-api-token

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

bootstrap-env:
	@test "$(ENV)" != "dev" || (echo "Set ENV=staging or ENV=prod"; exit 1)
	@mkdir -p live/$(ENV)
	@for s in identity apps policies authz governance; do \
	  if [ ! -d live/$(ENV)/$$s ]; then \
	    cp -R live/dev/$$s live/$(ENV)/$$s; \
	    echo "Created live/$(ENV)/$$s"; \
	    sed -i 's|/dev/|/$(ENV)/|g' live/$(ENV)/$$s/backend.hcl.example 2>/dev/null || true; \
	    sed -i 's|/dev/|/$(ENV)/|g' live/$(ENV)/$$s/terraform.tfvars.example 2>/dev/null || true; \
	  else \
	    echo "Skip live/$(ENV)/$$s (already exists)"; \
	  fi; \
	done
	@echo "Done. Edit backend.hcl and terraform.tfvars under live/$(ENV)/*"

gen-oidc-key:
	@mkdir -p .secrets
	@openssl genrsa -out .secrets/okta-tf-private.pem 2048
	@openssl rsa -in .secrets/okta-tf-private.pem -pubout -out .secrets/okta-tf-public.pem
	@chmod 600 .secrets/okta-tf-private.pem
	@echo "Created .secrets/okta-tf-private.pem and .secrets/okta-tf-public.pem"

check-no-api-token:
	@if grep -RIn --include='*.tf' --include='*.hcl' -E 'api_token\s*=|OKTA_API_TOKEN' live modules shared 2>/dev/null; then \
	  echo "ERROR: api_token forbidden. Use OIDC. See docs/AUTH.md"; exit 1; \
	else echo "OK: no API token usage found"; fi

fmt:
	terraform fmt -recursive

validate:
	@for stack in identity apps policies authz governance; do \
	  dir=live/dev/$$stack; echo "==> validate $$dir"; \
	  printf '%s\n' 'terraform { backend "local" {} }' > $$dir/backend_override.tf; \
	  (cd $$dir && terraform init -backend=false -input=false >/dev/null); \
	  (cd $$dir && terraform validate) || true; \
	  rm -f $$dir/backend_override.tf; \
	done

lint:
	@command -v tflint >/dev/null || { echo "Install tflint first"; exit 1; }
	@tflint --init 2>/dev/null || true
	@for d in modules/groups modules/apps/oauth modules/apps/saml modules/policies/signon modules/policies/mfa modules/policies/password modules/auth-servers modules/authenticators modules/network modules/trusted-origins modules/admin-roles modules/users modules/governance/labels; do \
	  echo "==> tflint $$d"; (cd $$d && tflint --format compact) || true; \
	done

ci-local: check-no-api-token fmt validate lint
	@echo "ci-local complete"
