terraform {
  backend "s3" {
    bucket         = "tfstate-coderco-dev-eu-west-2"
    key            = "state/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "tfstate-lock-coderco-dev"
    encrypt        = true
  }
}
