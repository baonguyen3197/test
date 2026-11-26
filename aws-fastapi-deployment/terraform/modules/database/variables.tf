variable "name" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "engine" { type = string }
variable "engine_version" { type = string }
variable "instance_class" { type = string }
variable "database_name" { type = string }
variable "username" { type = string }
variable "allocated_storage" { type = number }
variable "storage_type" { type = string }
variable "iops" { type = number }
variable "storage_encrypted" { type = bool }
variable "backup_retention_period" { type = number }
variable "deletion_protection" { type = bool }
variable "skip_final_snapshot" { type = bool }
variable "final_snapshot_identifier" {
  type     = string
  default  = null
  nullable = true
}
