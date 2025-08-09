## WIP

# Opinionated Terraform

This is an opinionated terraform repo style that I look at for reference when writing Terraform at scale. 

Production-grade Terraform for AWS with **multi-environment stacks**, **reusable modules**, **GitHub OIDC (no static keys)**, **LocalStack first-class** and **policy + security** baked in.

## Quickstart

```bash
# 1) Bootstrap remote state (run once per env)
cd tools/bootstrap-backend
terraform init
terraform apply -auto-approve -var="org=coderco" -var="env=dev" -var="region=eu-west-2"
terraform apply -auto-approve -var="org=coderco" -var="env=staging" -var="region=eu-west-2"
terraform apply -auto-approve -var="org=coderco" -var="env=prod" -var="region=eu-west-2"

# 2) Configure GitHub OIDC roles in AWS (see IAM JSON below)

# 3) Repo setup
pre-commit install

# 4) Plan Dev
make init plan ENV=dev

# 5) Apply Dev (manually/local)
make apply ENV=dev
```

### 2) Configure OIDC roles in AWS

Create two IAM roles with GitHub OIDC trust and policies. 

Set your repo/environment vars:

- Repo Actions → Variables: AWS_ACCOUNT_ID (used by CI).
- Repo Secrets: INFRACOST_API_KEY.

### 3) Use the stacks

```bash
# dev
cd stacks/dev && terraform init && terraform plan
# staging/prod similar
```

4) LocalStack

```bash
cd localstack
docker compose up -d
cd ../stacks/local
terraform init && terraform plan
```

### 5) CI flow (Mermaid)

```mermaid
flowchart LR
  A[PR opened] --> B[pre-commit: fmt/validate/tflint/tfsec/checkov/docs]
  A --> C[LocalStack plan + Terratest]
  A --> D[Plan per changed env via OIDC plan-role]
  D -->|Artifacts| E[Review]
  E -->|Merge| F[Apply main via OIDC apply-role]
  F --> G[Nightly drift plans]

```

### Localstack caveats

| Service | Used       | Notes                                           |
| ------- | ---------- | ----------------------------------------------- |
| S3/DDB  | ✅          | State backend for `local` is local (no remote). |
| ECR     | ✅          | Repo metadata only.                             |
| EC2     | ✅          | For VPC/subnets/IGW/NAT stubs.                  |
| RDS/EKS | ❌ in local | Not created in `stacks/local` by design.        |

### Troubleshooting

- OIDC failed to assume role: verify trust JSON sub matches repo and branch (pull_request or ref:refs/heads/main).

- tflint ruleset missing: run tflint --init once locally.

- terraform-docs changed READMEs in CI: run pre-commit run terraform_docs -a and commit.

- Backend access denied: ensure apply/plan roles include S3/DDB perms above.

### Extending

- New env: copy stacks/dev → stacks/<env>, adjust backend bucket/table names and variables.

- New module: create under modules/<name>, add examples/, run terraform-docs, wire CI in reusable workflow.

- More OPA: add rules under tools/policies/ and make conftest.

