data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_acm_certificate" "selected" {
  count    = var.certificate_arn == null ? 1 : 0
  domain   = var.certificate_domain_name
  statuses = ["ISSUED"]
  types    = ["AMAZON_ISSUED"]

  most_recent = true
}

locals {
  region = coalesce(var.region, data.aws_region.current.region)
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : slice(
    data.aws_availability_zones.available.names,
    0,
    var.availability_zone_count
  )
  certificate_arn = coalesce(var.certificate_arn, try(data.aws_acm_certificate.selected[0].arn, null))
  application_image = coalesce(
    var.application_image,
    "${module.ecr.repository_url}:${var.image_tag}"
  )
}

module "networking" {
  source = "./modules/networking"

  name                   = var.name
  availability_zones     = local.availability_zones
  vpc_cidr               = var.vpc_cidr
  public_subnet_count    = var.public_subnet_count
  private_subnet_count   = var.private_subnet_count
  nat_gateway_count      = var.nat_gateway_count
  public_subnet_newbits  = var.public_subnet_newbits
  private_subnet_newbits = var.private_subnet_newbits
  public_subnet_offset   = var.public_subnet_offset
  private_subnet_offset  = var.private_subnet_offset
}

module "security" {
  source = "./modules/security"

  name                 = var.name
  vpc_id               = module.networking.vpc_id
  alb_ingress_cidrs    = var.alb_ingress_cidrs
  application_port     = var.application_port
  database_port        = var.database_port
  https_port           = var.https_port
  http_port            = var.http_port
  outbound_https_cidrs = var.outbound_https_cidrs
}

module "ecr" {
  source = "./modules/ecr"

  name                  = var.name
  image_tag_mutability  = var.ecr_image_tag_mutability
  scan_on_push          = var.ecr_scan_on_push
  image_retention_count = var.ecr_image_retention_count
}

module "database" {
  source = "./modules/database"

  name                      = var.name
  subnet_ids                = module.networking.private_subnet_ids
  security_group_id         = module.security.database_id
  engine                    = var.db_engine
  engine_version            = var.db_engine_version
  instance_class            = var.db_instance_class
  database_name             = var.db_name
  username                  = var.db_user
  allocated_storage         = var.db_allocated_storage
  storage_type              = var.db_storage_type
  iops                      = var.db_iops
  backup_retention_period   = var.db_backup_retention_period
  deletion_protection       = var.db_deletion_protection
  storage_encrypted         = var.db_storage_encrypted
  final_snapshot_identifier = var.db_final_snapshot_identifier
  skip_final_snapshot       = var.db_skip_final_snapshot
}

module "secrets" {
  source = "./modules/secrets"

  secret_arn          = module.database.secret_arn
  rotation_enabled    = var.db_secret_rotation_enabled
  rotation_lambda_arn = var.db_secret_rotation_lambda_arn
}

module "alb" {
  source = "./modules/alb"

  name                 = var.name
  vpc_id               = module.networking.vpc_id
  subnet_ids           = module.networking.public_subnet_ids
  security_group_id    = module.security.alb_id
  certificate_arn      = local.certificate_arn
  application_port     = var.application_port
  http_port            = var.http_port
  https_port           = var.https_port
  health_check_path    = var.health_check_path
  health_check_matcher = var.health_check_matcher
  healthy_threshold    = var.healthy_threshold
  unhealthy_threshold  = var.unhealthy_threshold
  ssl_policy           = var.ssl_policy
}

module "monitoring" {
  source = "./modules/monitoring"

  name              = var.name
  retention_in_days = var.log_retention_in_days
}

module "ecs" {
  source = "./modules/ecs"

  name                       = var.name
  region                     = local.region
  image                      = local.application_image
  subnet_ids                 = slice(module.networking.private_subnet_ids, 0, var.application_az_count)
  security_group_id          = module.security.ecs_id
  target_group_arn           = module.alb.target_group_arn
  ecr_repository_arn         = module.ecr.repository_arn
  log_group_name             = module.monitoring.log_group_name
  log_group_arn              = module.monitoring.log_group_arn
  database_host              = module.database.endpoint
  database_port              = var.database_port
  database_name              = module.database.database_name
  database_username          = module.database.username
  database_secret_arn        = module.database.secret_arn
  tasks_per_az               = var.tasks_per_az
  application_port           = var.application_port
  task_cpu                   = var.task_cpu
  task_memory                = var.task_memory
  assign_public_ip           = var.assign_public_ip
  execution_role_policy_name = var.ecs_execution_role_policy_name
}
