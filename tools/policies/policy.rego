package terraform

deny[msg] {
  input.resource_type == "aws_s3_bucket_public_access_block"
  not input.body.block_public_acls
  msg := "S3 public access must be blocked"
}

deny[msg] {
  input.resource_type == "aws_s3_bucket"
  not input.has_sse
  msg := "S3 buckets must enable encryption"
}

deny[msg] {
  input.resource_type == "aws_db_instance"
  not input.body.storage_encrypted
  msg := "RDS storage_encrypted must be true"
}

deny[msg] {
  required := {"Name","Environment","Owner","CostCenter","ManagedBy","Repo","GitCommit"}
  missing := required - input.tags_set
  count(missing) > 0
  msg := sprintf("Missing required tags: %v", [missing])
}