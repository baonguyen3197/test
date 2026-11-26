resource "aws_security_group" "alb" {
  name   = "${var.name}-alb"
  vpc_id = var.vpc_id
}

resource "aws_security_group" "ecs" {
  name   = "${var.name}-ecs"
  vpc_id = var.vpc_id
}

resource "aws_security_group" "database" {
  name   = "${var.name}-database"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "alb" {
  for_each          = toset(concat([for cidr in var.alb_ingress_cidrs : "http:${cidr}"], [for cidr in var.alb_ingress_cidrs : "https:${cidr}"]))
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = split(":", each.value)[1]
  ip_protocol       = "tcp"
  from_port         = startswith(each.value, "http:") ? var.http_port : var.https_port
  to_port           = startswith(each.value, "http:") ? var.http_port : var.https_port
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ecs" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.ecs.id
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
}

resource "aws_vpc_security_group_egress_rule" "ecs_https" {
  for_each          = toset(var.outbound_https_cidrs)
  security_group_id = aws_security_group.ecs.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = var.https_port
  to_port           = var.https_port
}

resource "aws_vpc_security_group_egress_rule" "ecs_to_database" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.database.id
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
}

resource "aws_vpc_security_group_ingress_rule" "database_from_ecs" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = aws_security_group.ecs.id
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
}
