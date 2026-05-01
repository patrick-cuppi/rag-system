output "backend_repository_url" {
  description = "Backend ECR repository URL"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_repository_url" {
  description = "Frontend ECR repository URL"
  value       = aws_ecr_repository.frontend.repository_url
}

output "otel_collector_repository_url" {
  description = "OTEL Collector ECR repository URL"
  value       = aws_ecr_repository.otel_collector.repository_url
}

output "prometheus_repository_url" {
  description = "Prometheus ECR repository URL"
  value       = aws_ecr_repository.prometheus.repository_url
}

output "all_repository_arns" {
  description = "All ECR repository ARNs (for IAM policies)"
  value = [
    aws_ecr_repository.backend.arn,
    aws_ecr_repository.frontend.arn,
    aws_ecr_repository.otel_collector.arn,
    aws_ecr_repository.prometheus.arn,
  ]
}
