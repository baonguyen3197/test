output "identifier" { value = aws_db_instance.this.identifier }
output "endpoint" { value = aws_db_instance.this.address }
output "database_name" { value = aws_db_instance.this.db_name }
output "username" { value = aws_db_instance.this.username }
output "secret_arn" { value = aws_db_instance.this.master_user_secret[0].secret_arn }
