data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${var.name}-execution"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "execution" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    actions   = ["ecr:BatchCheckLayerAvailability", "ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer"]
    resources = [var.ecr_repository_arn]
  }
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${var.log_group_arn}:*"]
  }
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.database_secret_arn]
  }
}

resource "aws_iam_role_policy" "execution" {
  name   = var.execution_role_policy_name
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.execution.json
}

resource "aws_ecs_cluster" "this" {
  name = var.name
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.execution.arn
  container_definitions = jsonencode([{
    name      = var.container_name
    image     = var.image
    essential = true
    portMappings = [{
      containerPort = var.application_port
      protocol      = "tcp"
    }]
    environment = [
      { name = "DB_HOST", value = var.database_host },
      { name = "DB_PORT", value = tostring(var.database_port) },
      { name = "DB_NAME", value = var.database_name },
      { name = "DB_USER", value = var.database_username }
    ]
    secrets = [{ name = "DB_PASSWORD", valueFrom = "${var.database_secret_arn}:password::" }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.log_group_name
        awslogs-region        = var.region
        awslogs-stream-prefix = var.log_stream_prefix
      }
    }
  }])
}

resource "aws_ecs_service" "this" {
  count           = length(var.subnet_ids)
  name            = "${var.name}-${count.index}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = var.tasks_per_az
  network_configuration {
    subnets          = [var.subnet_ids[count.index]]
    security_groups  = [var.security_group_id]
    assign_public_ip = var.assign_public_ip
  }
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.application_port
  }
  depends_on = [aws_iam_role_policy.execution]
}
