variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

# Container images
variable "backend_image" {
  description = "Backend Docker image URI"
  type        = string
}

variable "frontend_image" {
  description = "Frontend Docker image URI"
  type        = string
}

variable "otel_collector_image" {
  description = "OTEL Collector Docker image URI"
  type        = string
}

variable "prometheus_image" {
  description = "Prometheus Docker image URI"
  type        = string
}

# Connection strings
variable "database_url" {
  description = "PostgreSQL connection string"
  type        = string
  sensitive   = true
}

variable "redis_url" {
  description = "Redis connection string"
  type        = string
}

# Secrets
variable "secrets_arns" {
  description = "Map of Secrets Manager ARNs"
  type        = map(string)
}

# Task sizing
variable "backend_cpu" {
  description = "CPU units for backend"
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Memory (MiB) for backend"
  type        = number
  default     = 512
}

variable "frontend_cpu" {
  description = "CPU units for frontend"
  type        = number
  default     = 256
}

variable "frontend_memory" {
  description = "Memory (MiB) for frontend"
  type        = number
  default     = 512
}

variable "worker_cpu" {
  description = "CPU units for worker"
  type        = number
  default     = 512
}

variable "worker_memory" {
  description = "Memory (MiB) for worker"
  type        = number
  default     = 1024
}
