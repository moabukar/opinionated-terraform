variable "region" {
  type    = string
  default = "eu-west-2"
}
variable "vpc_cidr" {
  type    = string
  default = "10.100.0.0/16"
}
variable "localstack_endpoint" {
  type    = string
  default = "http://localhost:4566"
}
