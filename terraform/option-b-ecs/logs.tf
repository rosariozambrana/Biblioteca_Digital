resource "aws_cloudwatch_log_group" "nats" {
  name              = "/ecs/${var.project_name}/nats"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "catalog" {
  name              = "/ecs/${var.project_name}/catalog"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "loans" {
  name              = "/ecs/${var.project_name}/loans"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "notifications" {
  name              = "/ecs/${var.project_name}/notifications"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "rds" {
  name              = "/ecs/${var.project_name}/rds"
  retention_in_days = 7
}
