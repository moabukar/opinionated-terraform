variable "name" { type = string }
variable "cidr" { type = string }
variable "az_count" {
  type    = number
  default = 3
}
variable "public_subnets" {
  type        = list(string)
  default     = []
  description = "Leave empty for private-only"
}
variable "private_subnets" {
  type = list(string)
}

variable "nat_gateways" {
  type        = number
  description = "0 for no NAT; 1 for single AZ; up to az_count"
  default     = 1
}

variable "enable_flow_logs" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
