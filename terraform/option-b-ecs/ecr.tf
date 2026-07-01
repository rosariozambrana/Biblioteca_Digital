resource "aws_ecr_repository" "catalog" {
  name                 = "${var.project_name}/catalog"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "loans" {
  name                 = "${var.project_name}/loans"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "notifications" {
  name                 = "${var.project_name}/notifications"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Bloque agregado para que outputs.tf pueda usar local.ecr_registry
data "aws_caller_identity" "current" {}

locals {
  ecr_registry = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"

  ecr_lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Mantener las ultimas 10 imagenes"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}

resource "aws_ecr_lifecycle_policy" "catalog" {
  repository = aws_ecr_repository.catalog.name
  policy     = local.ecr_lifecycle_policy
}

resource "aws_ecr_lifecycle_policy" "loans" {
  repository = aws_ecr_repository.loans.name
  policy     = local.ecr_lifecycle_policy
}

resource "aws_ecr_lifecycle_policy" "notifications" {
  repository = aws_ecr_repository.notifications.name
  policy     = local.ecr_lifecycle_policy
}
