package terraform.security

deny[msg] {
  input.resource_type == "aws_s3_bucket"
  public := input.values.acl
  public == "public-read" or public == "public-read-write"
  msg := sprintf("S3 bucket %s should not be public", [input.address])
}

deny[msg] {
  input.resource_type == "aws_s3_bucket"
  not input.values.server_side_encryption_configuration
  msg := sprintf("S3 bucket %s must enable encryption", [input.address])
}

deny[msg] {
  input.resource_type == "aws_db_instance"
  not input.values.storage_encrypted
  msg := sprintf("RDS %s must have storage_encrypted = true", [input.address])
}

# Required tags on all taggable resources
required_tags := {"Name", "Environment", "Owner", "CostCenter", "ManagedBy", "Repo", "GitCommit"}

deny[msg] {
  input.values.tags
  some t
  t := required_tags[_]
  not input.values.tags[t]
  msg := sprintf("Resource %s missing required tag %s", [input.address, t])
}
