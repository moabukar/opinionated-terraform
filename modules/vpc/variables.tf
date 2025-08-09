variable "name" {
  type = string
}
variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "az_count" {
  type    = number
  default = 3
}
variable "create_public_subnets" {
  type    = bool
  default = true
}
variable "nat_gateway_count" {
  type    = number
  default = 1
}
variable "enable_flow_logs" {
  description = "Enable VPC flow logs and supporting resources (KMS, IAM, CloudWatch)"
  type        = bool
  default     = false
}
variable "tags" {
  type    = map(string)
  default = {}
}
