# ──────────────────────────────────────────────
# Networking
# ──────────────────────────────────────────────

output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

# ──────────────────────────────────────────────
# ECR
# ──────────────────────────────────────────────

output "ecr_backend_url" {
  description = "Backend ECR repository URL"
  value       = module.ecr.backend_repository_url
}

output "ecr_frontend_url" {
  description = "Frontend ECR repository URL"
  value       = module.ecr.frontend_repository_url
}

# ──────────────────────────────────────────────
# ECS
# ──────────────────────────────────────────────

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "alb_url" {
  description = "Application URL (ALB DNS)"
  value       = "http://${module.ecs.alb_dns_name}"
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = "http://${module.ecs.alb_dns_name}:3001"
}

output "jaeger_url" {
  description = "Jaeger tracing UI URL"
  value       = "http://${module.ecs.alb_dns_name}:16686"
}

output "prometheus_url" {
  description = "Prometheus UI URL"
  value       = "http://${module.ecs.alb_dns_name}:9090"
}

# ──────────────────────────────────────────────
# Database
# ──────────────────────────────────────────────

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.database.endpoint
  sensitive   = true
}

# ──────────────────────────────────────────────
# GitHub Actions
# ──────────────────────────────────────────────

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC (use in deploy workflow)"
  value       = aws_iam_role.github_actions.arn
}
