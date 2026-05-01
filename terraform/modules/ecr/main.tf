# ──────────────────────────────────────────────
# ECR Repositories
# ──────────────────────────────────────────────

resource "aws_ecr_repository" "backend" {
  name                 = "${var.name_prefix}-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.name_prefix}-backend"
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "${var.name_prefix}-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.name_prefix}-frontend"
  }
}

resource "aws_ecr_repository" "otel_collector" {
  name                 = "${var.name_prefix}-otel-collector"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.name_prefix}-otel-collector"
  }
}

resource "aws_ecr_repository" "prometheus" {
  name                 = "${var.name_prefix}-prometheus"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.name_prefix}-prometheus"
  }
}

# ──────────────────────────────────────────────
# Lifecycle Policies — keep only last 10 images
# ──────────────────────────────────────────────

resource "aws_ecr_lifecycle_policy" "cleanup" {
  for_each = {
    backend        = aws_ecr_repository.backend.name
    frontend       = aws_ecr_repository.frontend.name
    otel_collector = aws_ecr_repository.otel_collector.name
    prometheus     = aws_ecr_repository.prometheus.name
  }

  repository = each.value

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
