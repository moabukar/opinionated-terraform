package terraform.security

test_s3_public_denied {
  deny[msg] with input as {
    "address": "aws_s3_bucket.bad",
    "resource_type": "aws_s3_bucket",
    "values": {"acl": "public-read"}
  }
}

test_rds_encryption_required {
  deny[msg] with input as {
    "address": "aws_db_instance.noenc",
    "resource_type": "aws_db_instance",
    "values": {"storage_encrypted": false}
  }
}

test_missing_tags_denied {
  deny[msg] with input as {
    "address": "aws_vpc.bad",
    "resource_type": "aws_vpc",
    "values": {"tags": {"Name": "x"}}
  }
}
