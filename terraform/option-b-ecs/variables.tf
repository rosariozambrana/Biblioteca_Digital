variable "aws_region" {
  description = "Región de AWS donde se desplegará todo."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefijo para nombrar todos los recursos."
  type        = string
  default     = "biblioteca-digital"
}

variable "vpc_cidr" {
  description = "Bloque CIDR de la VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs de las subnets públicas (una por AZ)."
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "azs" {
  description = "Availability Zones a usar."
  type        = list(string)
  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "catalog_desired_count" {
  description = "Número de tareas Fargate para catalog."
  type        = number
  default     = 1
}

variable "loans_desired_count" {
  description = "Número de tareas Fargate para loans."
  type        = number
  default     = 1
}

variable "notifications_desired_count" {
  description = "Número de tareas Fargate para notifications."
  type        = number
  default     = 1
}

variable "task_cpu" {
  description = "CPU por tarea Fargate."
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memoria por tarea Fargate."
  type        = string
  default     = "512"
}

variable "image_tag" {
  description = "Tag de las imágenes Docker."
  type        = string
  default     = "latest"
}

variable "db_username" {
  description = "Usuario de PostgreSQL."
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Contraseña de PostgreSQL."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nombre de la base de datos."
  type        = string
  default     = "biblioteca"
}

variable "db_instance_class" {
  description = "Tipo de instancia RDS."
  type        = string
  default     = "db.t3.micro"
}

variable "acm_certificate_arn" {
  description = "ARN del certificado ACM."
  type        = string
  sensitive   = true
}