resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Permite HTTP entrante desde internet hacia el ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP desde internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-alb-sg" }
}

resource "aws_security_group" "catalog" {
  name        = "${var.project_name}-catalog-sg"
  description = "Permite trafico solo desde el ALB hacia catalog:3000"
  vpc_id      = aws_vpc.main.id

ingress {
  description = "Tráfico desde ALB hacia Catalog"
  from_port   = 3000
  to_port     = 3000
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-catalog-sg" }
}

resource "aws_security_group" "loans" {
  name        = "${var.project_name}-loans-sg"
  description = "loans no acepta entrante (microservicio NATS puro)"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-loans-sg" }
}

resource "aws_security_group" "notifications" {
  name        = "${var.project_name}-notifications-sg"
  description = "notifications no acepta entrante (microservicio NATS puro)"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-notifications-sg" }
}

resource "aws_security_group" "nats" {
  name        = "${var.project_name}-nats-sg"
  description = "Broker NATS: ingreso solo desde catalog, loans y notifications"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-nats-sg" }
}

# Reglas separadas para evitar dependencias circulares entre SGs.
resource "aws_vpc_security_group_ingress_rule" "nats_from_catalog" {
  security_group_id            = aws_security_group.nats.id
  referenced_security_group_id = aws_security_group.catalog.id
  ip_protocol                  = "tcp"
  from_port                    = 4222
  to_port                      = 4222
  description                  = "NATS desde catalog"
}

resource "aws_vpc_security_group_ingress_rule" "nats_from_loans" {
  security_group_id            = aws_security_group.nats.id
  referenced_security_group_id = aws_security_group.loans.id
  ip_protocol                  = "tcp"
  from_port                    = 4222
  to_port                      = 4222
  description                  = "NATS desde loans"
}

resource "aws_vpc_security_group_ingress_rule" "nats_from_notifications" {
  security_group_id            = aws_security_group.nats.id
  referenced_security_group_id = aws_security_group.notifications.id
  ip_protocol                  = "tcp"
  from_port                    = 4222
  to_port                      = 4222
  description                  = "NATS desde notifications"
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "RDS PostgreSQL: ingreso solo desde catalog, loans y notifications"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "${var.project_name}-rds-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_catalog" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.catalog.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  description                  = "PostgreSQL desde catalog"
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_loans" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.loans.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  description                  = "PostgreSQL desde loans"
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_notifications" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.notifications.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  description                  = "PostgreSQL desde notifications"
}
