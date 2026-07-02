resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP/HTTPS inbound from internet to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
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
  description = "Allow traffic only from ALB to catalog:3000"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-catalog-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "catalog_from_alb" {
  security_group_id            = aws_security_group.catalog.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 3000
  to_port                      = 3000
  description                  = "Traffic from ALB to Catalog"
}

resource "aws_security_group" "loans" {
  name        = "${var.project_name}-loans-sg"
  description = "Loans service does not accept inbound (NATS only)"
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
  description = "Notifications service does not accept inbound (NATS only)"
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
  description = "NATS broker: inbound only from catalog, loans, notifications"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-nats-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "nats_from_catalog" {
  security_group_id            = aws_security_group.nats.id
  referenced_security_group_id = aws_security_group.catalog.id
  ip_protocol                  = "tcp"
  from_port                    = 4222
  to_port                      = 4222
  description                  = "NATS from catalog"
}

resource "aws_vpc_security_group_ingress_rule" "nats_from_loans" {
  security_group_id            = aws_security_group.nats.id
  referenced_security_group_id = aws_security_group.loans.id
  ip_protocol                  = "tcp"
  from_port                    = 4222
  to_port                      = 4222
  description                  = "NATS from loans"
}

resource "aws_vpc_security_group_ingress_rule" "nats_from_notifications" {
  security_group_id            = aws_security_group.nats.id
  referenced_security_group_id = aws_security_group.notifications.id
  ip_protocol                  = "tcp"
  from_port                    = 4222
  to_port                      = 4222
  description                  = "NATS from notifications"
}
