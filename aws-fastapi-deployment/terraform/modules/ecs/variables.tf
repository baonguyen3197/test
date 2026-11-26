variable "name" { type = string }
variable "region" { type = string }
variable "image" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "target_group_arn" { type = string }
variable "ecr_repository_arn" { type = string }
variable "log_group_name" { type = string }
variable "log_group_arn" { type = string }
variable "database_host" { type = string }
variable "database_port" { type = number }
variable "database_name" { type = string }
variable "database_username" { type = string }
variable "database_secret_arn" { type = string }
variable "tasks_per_az" { type = number }
variable "application_port" { type = number }
variable "task_cpu" { type = string }
variable "task_memory" { type = string }
variable "assign_public_ip" { type = bool }
variable "execution_role_policy_name" { type = string }
variable "container_name" {
  type    = string
  default = "api"
}
variable "log_stream_prefix" {
  type    = string
  default = "api"
}
