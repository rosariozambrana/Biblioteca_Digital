output "alb_dns_name" {
  description = "URL pública del ALB — punto de entrada al sistema."
  value       = aws_lb.main.dns_name
}

output "ecr_catalog_repository_url" {
  description = "URL del repo ECR para catalog."
  value       = aws_ecr_repository.catalog.repository_url
}

output "ecr_loans_repository_url" {
  description = "URL del repo ECR para loans."
  value       = aws_ecr_repository.loans.repository_url
}

output "ecr_notifications_repository_url" {
  description = "URL del repo ECR para notifications."
  value       = aws_ecr_repository.notifications.repository_url
}

output "ecr_login_command" {
  description = "comando para autenticar Docker contra ECR."
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${local.ecr_registry}"
}

output "cluster_name" {
  description = "Nombre del cluster ECS."
  value       = aws_ecs_cluster.main.name
}

output "service_discovery_namespace" {
  description = "Namespace DNS interno."
  value       = aws_service_discovery_private_dns_namespace.main.name
}

output "rds_endpoint" {
  description = "Endpoint de la instancia RDS PostgreSQL."
  value       = aws_db_instance.postgres.address
}
