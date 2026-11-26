variable "secret_arn" { type = string }
variable "rotation_enabled" { type = bool }
variable "rotation_lambda_arn" {
  type     = string
  default  = null
  nullable = true
  validation {
    condition     = var.rotation_enabled == false || var.rotation_lambda_arn != null
    error_message = "rotation_lambda_arn is required when rotation_enabled is true."
  }
}
