variable "name" { type = string }
variable "vpc_id" { type = string }
variable "alb_ingress_cidrs" { type = list(string) }
variable "outbound_https_cidrs" { type = list(string) }
variable "application_port" { type = number }
variable "database_port" { type = number }
variable "http_port" { type = number }
variable "https_port" { type = number }
