ENV ?= dev
REGION ?= eu-west-2

S := @

.PHONY: bootstrap init validate plan apply destroy lint security docs test drift
bootstrap:
	$(S)cd tools/bootstrap-backend && terraform init && terraform apply -auto-approve -var="org=coderco" -var="env=$(ENV)" -var="region=$(REGION)"

init:
	$(S)cd stacks/$(ENV) && terraform init -input=false

validate:
	$(S)cd stacks/$(ENV) && terraform validate

plan:
	$(S)cd stacks/$(ENV) && terraform plan -input=false -out=plan.out

apply:
	$(S)cd stacks/$(ENV) && terraform apply -auto-approve

destroy:
	$(S)cd stacks/$(ENV) && terraform destroy -auto-approve

lint:
	$(S)pre-commit run -a || true
	$(S)tflint --init && tflint

security:
	$(S)tfsec . || true
	$(S)checkov -d .

docs:
	$(S)terraform-docs markdown table --output-file README.md --output-mode replace modules/vpc
	$(S)terraform-docs markdown table --output-file README.md --output-mode replace modules/ecr
	$(S)terraform-docs markdown table --output-file README.md --output-mode replace modules/rds
	$(S)terraform-docs markdown table --output-file README.md --output-mode replace modules/eks

test:
	$(S)cd test && go test -v -timeout 45m ./...

drift:
	$(S)for e in dev staging prod; do (cd stacks/$$e && terraform init -input=false && terraform plan -detailed-exitcode || true); done

# LocalStack helpers
ls:up:
	$(S)cd localstack && docker compose up -d

ls:down:
	$(S)cd localstack && docker compose down -v

ls:reset: ls:down ls:up

conftest:
	$(S)conftest test -p tools/policies .
