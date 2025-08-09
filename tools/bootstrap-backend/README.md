# Backend Bootstrap

Creates per-env remote state in S3 with versioning/encryption/logging and DDB lock table.

## Usage

```bash
terraform init
terraform apply -auto-approve -var="org=coderco" -var="env=dev" -var="region=eu-west-2"
terraform apply -auto-approve -var="org=coderco" -var="env=staging" -var="region=eu-west-2"
terraform apply -auto-approve -var="org=coderco" -var="env=prod" -var="region=eu-west-2"

Buckets: tfstate-coderco-<env>-<region>
Tables: tfstate-lock-coderco-<env>
```

## Variables

- `org`: Your organization name (e.g. "coderco").
- `env`: Environment name (e.g. "dev", "staging", "prod").
- `region`: AWS region (e.g. "eu-west-2").

## Outputs