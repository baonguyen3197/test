resource "aws_db_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "this" {
  identifier                  = var.name
  engine                      = var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [var.security_group_id]
  db_name                     = var.database_name
  username                    = var.username
  manage_master_user_password = true
  multi_az                    = true
  publicly_accessible         = false
  allocated_storage           = var.allocated_storage
  storage_type                = var.storage_type
  iops                        = var.iops
  storage_encrypted           = var.storage_encrypted
  backup_retention_period     = var.backup_retention_period
  deletion_protection         = var.deletion_protection
  skip_final_snapshot         = var.skip_final_snapshot
  final_snapshot_identifier   = var.skip_final_snapshot ? null : coalesce(var.final_snapshot_identifier, "${var.name}-final")
}
