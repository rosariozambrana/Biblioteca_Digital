resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id          = data.aws_caller_identity.current.account_id
  ecr_registry        = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  catalog_image       = "${aws_ecr_repository.catalog.repository_url}:${var.image_tag}"
  # COMPAÑEROS: Faltan variables locales aquí (loans_image, database_url)
  notifications_image = "${aws_ecr_repository.notifications.repository_url}:${var.image_tag}"

  nats_dns_url = "nats://nats.${aws_service_discovery_private_dns_namespace.main.name}:4222"
}

# ------------------------------------------------------------------
# NATS
# ------------------------------------------------------------------
resource "aws_ecs_task_definition" "nats" {
  family                   = "${var.project_name}-nats"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([{
    name      = "nats"
    image     = "nats:2.10-alpine"
    essential = true
    command   = ["-js", "-m", "8222"]
    portMappings = [
      { containerPort = 4222, protocol = "tcp" },
      { containerPort = 8222, protocol = "tcp" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.nats.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "nats"
      }
    }
  }])
}

resource "aws_ecs_service" "nats" {
  name            = "nats"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nats.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.nats.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.nats.arn
  }
}

# ------------------------------------------------------------------
# catalog (HTTP)
# ------------------------------------------------------------------
resource "aws_ecs_task_definition" "catalog" {
  family                   = "${var.project_name}-catalog"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([{
    name      = "catalog"
    image     = local.catalog_image
    essential = true
    portMappings = [
      { containerPort = 3000, protocol = "tcp" }
    ]
    environment = [
      { name = "NATS_URL",          value = local.nats_dns_url },
      # COMPAÑEROS: Falta la variable de entorno para la Base de Datos
      { name = "CATALOG_HTTP_PORT", value = "3000" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.catalog.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "catalog"
      }
    }
  }])
}

resource "aws_ecs_service" "catalog" {
  name            = "catalog"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.catalog.arn
  desired_count   = var.catalog_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.catalog.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.catalog.arn
    container_name   = "catalog"
    container_port   = 3000
  }

  service_registries {
    registry_arn = aws_service_discovery_service.catalog.arn
  }

  depends_on = [aws_lb_listener.http]
}

# COMPAÑEROS: Falta la definición y el servicio ECS para el microservicio "loans"

# ------------------------------------------------------------------
# notifications (worker)
# ------------------------------------------------------------------
resource "aws_ecs_task_definition" "notifications" {
  family                   = "${var.project_name}-notifications"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([{
    name      = "notifications"
    image     = local.notifications_image
    essential = true
    environment = [
      { name = "NATS_URL",     value = local.nats_dns_url },
      # COMPAÑEROS: Falta la variable de entorno para la Base de Datos
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.notifications.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "notifications"
      }
    }
  }])
}

resource "aws_ecs_service" "notifications" {
  name            = "notifications"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.notifications.arn
  desired_count   = var.notifications_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.notifications.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.notifications.arn
  }
}
