provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Name        = "stacks-dev"
      Environment = "dev"
      Owner       = "platform@coderco.dev"
      CostCenter  = "ENG-PLATFORM"
      ManagedBy   = "Terraform"
      Repo        = "coderco/terraform-aws-mono"
      GitCommit   = ""
    }
  }
}

# optional pattern: read-only vs apply aliases
provider "aws" {
  alias  = "plan"
  region = var.region
}
provider "aws" {
  alias  = "apply"
  region = var.region
}
