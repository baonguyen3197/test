variable "name" { type = string }
variable "availability_zones" { type = list(string) }
variable "vpc_cidr" { type = string }
variable "public_subnet_count" { type = number }
variable "private_subnet_count" { type = number }
variable "nat_gateway_count" { type = number }
variable "public_subnet_newbits" { type = number }
variable "private_subnet_newbits" { type = number }
variable "public_subnet_offset" { type = number }
variable "private_subnet_offset" { type = number }
variable "internet_cidr" {
  type    = string
  default = "0.0.0.0/0"
}
