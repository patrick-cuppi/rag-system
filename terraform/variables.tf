# ──────────────────────────────────────────────
# General
# ──────────────────────────────────────────────

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used as prefix for all resources"
  type        = string
  default     = "rag-system"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

# ──────────────────────────────────────────────
# GitHub OIDC
# ──────────────────────────────────────────────

variable "github_org" {
  description = "GitHub username"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "rag-system"
}

# ──────────────────────────────────────────────
# Networking
# ──────────────────────────────────────────────

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to deploy across"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ──────────────────────────────────────────────
# Database
# ──────────────────────────────────────────────

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "ragdb"
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "raguser"
}

variable "db_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

# ──────────────────────────────────────────────
# Application Secrets
# ──────────────────────────────────────────────

variable "openai_api_key" {
  description = "OpenAI API key"
  type        = string
  sensitive   = true
}

variable "pinecone_api_key" {
  description = "Pinecone API key"
  type        = string
  sensitive   = true
}

variable "pinecone_index" {
  description = "Pinecone index name"
  type        = string
  default     = "rag-index"
}

variable "jwt_secret_key" {
  description = "JWT secret key for authentication"
  type        = string
  sensitive   = true
}

# ──────────────────────────────────────────────
# ECS Task Sizing
# ──────────────────────────────────────────────

variable "backend_cpu" {
  description = "CPU units for the backend task"
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Memory (MiB) for the backend task"
  type        = number
  default     = 512
}

variable "frontend_cpu" {
  description = "CPU units for the frontend task"
  type        = number
  default     = 256
}

variable "frontend_memory" {
  description = "Memory (MiB) for the frontend task"
  type        = number
  default     = 512
}

variable "worker_cpu" {
  description = "CPU units for the Celery worker task"
  type        = number
  default     = 512
}

variable "worker_memory" {
  description = "Memory (MiB) for the Celery worker task"
  type        = number
  default     = 1024
}

# ──────────────────────────────────────────────
# Domain (optional — configure when ready)
# ──────────────────────────────────────────────

variable "domain_name" {
  description = "Custom domain name (leave empty to use ALB DNS)"
  type        = string
  default     = ""
}
