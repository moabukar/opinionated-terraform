terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "org" { type = string }
variable "env" { type = string }
variable "region" { type = string }

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Owner       = "platform@coderco.dev"
      ManagedBy   = "Terraform"
      Repo        = "coderco/terraform-aws-mono"
      Environment = var.env
      CostCenter  = "ENG-PLATFORM"
    }
  }
}

locals {
  bucket_name = "tfstate-${var.org}-${var.env}-${var.region}"
  table_name  = "tfstate-lock-${var.org}-${var.env}"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "this" {
  bucket        = aws_s3_bucket.tfstate.id
  target_bucket = aws_s3_bucket.tfstate.id
  target_prefix = "access-logs/"
}

resource "aws_dynamodb_table" "lock" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  point_in_time_recovery { enabled = true }
}

output "bucket_name" { value = aws_s3_bucket.tfstate.bucket }
output "table_name" { value = aws_dynamodb_table.lock.name }
