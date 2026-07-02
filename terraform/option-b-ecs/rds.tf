# ------------------------------------------------------------
# RDS PostgreSQL
# ------------------------------------------------------------

# Subnet group para RDS (usa las subnets privadas)
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# Security Group para RDS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Permite acceso a PostgreSQL desde los microservicios ECS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL desde ECS"

    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    security_groups = [
      aws_security_group.catalog.id,
      aws_security_group.loans.id,
      aws_security_group.notifications.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# Instancia PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-db"

  engine         = "postgres"

  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  port = 5432

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  db_subnet_group_name = aws_db_subnet_group.main.name

  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false

  # Compatible con cuentas Free Tier
  backup_retention_period = 1

  # Desarrollo
  multi_az = false

  auto_minor_version_upgrade = true

  # Deshabilitado para evitar requerir IAM Role de Enhanced Monitoring
  monitoring_interval = 0

  tags = {
    Name        = "${var.project_name}-rds"
    Environment = "dev"
  }
}