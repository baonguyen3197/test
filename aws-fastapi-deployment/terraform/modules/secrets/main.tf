resource "aws_secretsmanager_secret_rotation" "this" {
  secret_id           = var.secret_arn
  rotation_enabled    = var.rotation_enabled
  rotation_lambda_arn = var.rotation_enabled ? var.rotation_lambda_arn : null
}
