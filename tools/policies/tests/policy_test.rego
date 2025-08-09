package terraform

test_s3_encryption_required {
  input := {"resource_type":"aws_s3_bucket","has_sse":false,"tags_set":{"Name"}}
  count(deny) >= 1
}
