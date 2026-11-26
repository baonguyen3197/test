variable "region" {
  description = "AWS region. If unset, Terraform uses AWS_REGION or AWS_DEFAULT_REGION."
  type        = string
  default     = null
  nullable    = true
}

variable "aws_account_id" {
  description = "Optional account guard. If unset, the active AWS profile account is accepted."
  type        = string
  default     = null
  nullable    = true
  validation {
    condition     = var.aws_account_id == null || can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must contain exactly 12 digits."
  }
}

variable "name" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,20}$", var.name))
    error_message = "Use a lowercase name starting with a letter, up to 21 characters."
  }
}

variable "availability_zones" {
  description = "Optional explicit AZs. When empty, Terraform selects available AZs from the active region."
  type        = list(string)
  default     = []
}

variable "availability_zone_count" {
  type    = number
  default = 2
  validation {
    condition     = var.availability_zone_count >= 2 && floor(var.availability_zone_count) == var.availability_zone_count
    error_message = "availability_zone_count must be an integer of at least two."
  }
}

variable "certificate_arn" {
  description = "Optional issued ACM certificate ARN. If unset, certificate_domain_name is used for discovery."
  type        = string
  default     = null
  nullable    = true
}

variable "certificate_domain_name" {
  description = "Domain on an issued regional ACM certificate; used when certificate_arn is unset."
  type        = string
  default     = null
  nullable    = true
  validation {
    condition     = var.certificate_arn != null || var.certificate_domain_name != null
    error_message = "Set certificate_arn or certificate_domain_name."
  }
}

variable "vpc_cidr" { type = string }
variable "public_subnet_count" {
  type    = number
  default = 2
}
variable "private_subnet_count" {
  type    = number
  default = 2
}
variable "nat_gateway_count" {
  type    = number
  default = 2
}
variable "public_subnet_newbits" {
  type    = number
  default = 8
}
variable "public_subnet_offset" {
  type    = number
  default = 0
}
variable "private_subnet_newbits" {
  type    = number
  default = 8
}
variable "private_subnet_offset" {
  type    = number
  default = 10
}

variable "application_az_count" {
  type    = number
  default = 2
  validation {
    condition     = var.application_az_count >= 1 && var.application_az_count <= min(var.public_subnet_count, var.private_subnet_count)
    error_message = "application_az_count must fit within the public and private subnet counts."
  }
}

variable "alb_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "outbound_https_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "application_port" {
  type    = number
  default = 8000
}
variable "database_port" {
  type    = number
  default = 5432
}
variable "http_port" {
  type    = number
  default = 80
}
variable "https_port" {
  type    = number
  default = 443
}

variable "application_image" {
  description = "Complete image URI override. If unset, ECR repository and image_tag are used."
  type        = string
  default     = null
  nullable    = true
}
variable "image_tag" {
  type    = string
  default = "latest"
}
variable "ecr_image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}
variable "ecr_scan_on_push" {
  type    = bool
  default = true
}
variable "ecr_image_retention_count" {
  type    = number
  default = 30
}
variable "tasks_per_az" {
  type    = number
  default = 0
}
variable "task_cpu" {
  type    = string
  default = "256"
}
variable "task_memory" {
  type    = string
  default = "512"
}
variable "assign_public_ip" {
  type    = bool
  default = false
}
variable "ecs_execution_role_policy_name" {
  type    = string
  default = "execution"
}

variable "db_engine" {
  type    = string
  default = "postgres"
}
variable "db_engine_version" { type = string }
variable "db_instance_class" { type = string }
variable "db_name" {
  type    = string
  default = "demodb"
}
variable "db_user" {
  type    = string
  default = "appadmin"
}
variable "db_allocated_storage" {
  type    = number
  default = 100
}
variable "db_storage_type" {
  type    = string
  default = "io1"
}
variable "db_iops" {
  type    = number
  default = 1000
}
variable "db_backup_retention_period" {
  type    = number
  default = 7
}
variable "db_deletion_protection" {
  type    = bool
  default = true
}
variable "db_storage_encrypted" {
  type    = bool
  default = true
}
variable "db_final_snapshot_identifier" {
  type     = string
  default  = null
  nullable = true
}
variable "db_skip_final_snapshot" {
  type    = bool
  default = false
}
variable "db_secret_rotation_enabled" {
  type    = bool
  default = false
}
variable "db_secret_rotation_lambda_arn" {
  type     = string
  default  = null
  nullable = true
}

variable "health_check_path" {
  type    = string
  default = "/health"
}
variable "health_check_matcher" {
  type    = string
  default = "200"
}
variable "healthy_threshold" {
  type    = number
  default = 2
}
variable "unhealthy_threshold" {
  type    = number
  default = 2
}
variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}
variable "log_retention_in_days" {
  type    = number
  default = 14
}
variable "tags" {
  type    = map(string)
  default = {}
}
