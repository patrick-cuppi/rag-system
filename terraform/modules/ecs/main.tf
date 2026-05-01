# ──────────────────────────────────────────────
# ECS Cluster
# ──────────────────────────────────────────────

resource "aws_ecs_cluster" "main" {
  name = "${var.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.name_prefix}-cluster"
  }
}

# ──────────────────────────────────────────────
# Cloud Map Namespace (Service Discovery)
# ──────────────────────────────────────────────

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.name_prefix}.local"
  description = "Service discovery for RAG system ECS tasks"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "otel_collector" {
  name = "otel-collector"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "jaeger" {
  name = "jaeger"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "backend" {
  name = "backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# ──────────────────────────────────────────────
# CloudWatch Log Groups
# ──────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${var.name_prefix}/backend"
  retention_in_days = 14

  tags = { Name = "${var.name_prefix}-backend-logs" }
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${var.name_prefix}/frontend"
  retention_in_days = 14

  tags = { Name = "${var.name_prefix}-frontend-logs" }
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "/ecs/${var.name_prefix}/worker"
  retention_in_days = 14

  tags = { Name = "${var.name_prefix}-worker-logs" }
}

resource "aws_cloudwatch_log_group" "otel_collector" {
  name              = "/ecs/${var.name_prefix}/otel-collector"
  retention_in_days = 14

  tags = { Name = "${var.name_prefix}-otel-collector-logs" }
}

resource "aws_cloudwatch_log_group" "jaeger" {
  name              = "/ecs/${var.name_prefix}/jaeger"
  retention_in_days = 14

  tags = { Name = "${var.name_prefix}-jaeger-logs" }
}

resource "aws_cloudwatch_log_group" "prometheus" {
  name              = "/ecs/${var.name_prefix}/prometheus"
  retention_in_days = 14

  tags = { Name = "${var.name_prefix}-prometheus-logs" }
}

resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/${var.name_prefix}/grafana"
  retention_in_days = 14

  tags = { Name = "${var.name_prefix}-grafana-logs" }
}

# ──────────────────────────────────────────────
# Task Definitions
# ──────────────────────────────────────────────

# --- Backend API ---
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.name_prefix}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = var.backend_image
      essential = true

      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "DATABASE_URL", value = var.database_url },
        { name = "REDIS_URL", value = var.redis_url },
        { name = "PINECONE_INDEX", value = "rag-index" },
        { name = "OTEL_EXPORTER_OTLP_ENDPOINT", value = "http://otel-collector.${var.name_prefix}.local:4317" },
        { name = "OTEL_SERVICE_NAME", value = "rag-backend" },
      ]

      secrets = [
        { name = "OPENAI_API_KEY", valueFrom = var.secrets_arns["openai_api_key"] },
        { name = "PINECONE_API_KEY", valueFrom = var.secrets_arns["pinecone_api_key"] },
        { name = "JWT_SECRET_KEY", valueFrom = var.secrets_arns["jwt_secret_key"] },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      command = ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
    }
  ])

  tags = {
    Name = "${var.name_prefix}-backend-task"
  }
}

# --- Frontend ---
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.name_prefix}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.frontend_cpu
  memory                   = var.frontend_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = var.frontend_image
      essential = true

      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "NEXT_PUBLIC_API_URL", value = "http://${aws_lb.main.dns_name}/api" },
        { name = "NODE_ENV", value = "production" },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.frontend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.name_prefix}-frontend-task"
  }
}

# --- Celery Worker ---
resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.name_prefix}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.worker_cpu
  memory                   = var.worker_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "worker"
      image     = var.backend_image # Same image as backend
      essential = true

      environment = [
        { name = "DATABASE_URL", value = var.database_url },
        { name = "REDIS_URL", value = var.redis_url },
        { name = "PINECONE_INDEX", value = "rag-index" },
        { name = "OTEL_EXPORTER_OTLP_ENDPOINT", value = "http://otel-collector.${var.name_prefix}.local:4317" },
        { name = "OTEL_SERVICE_NAME", value = "rag-worker" },
      ]

      secrets = [
        { name = "OPENAI_API_KEY", valueFrom = var.secrets_arns["openai_api_key"] },
        { name = "PINECONE_API_KEY", valueFrom = var.secrets_arns["pinecone_api_key"] },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.worker.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      command = ["celery", "-A", "app.worker.celery_app", "worker", "--loglevel=info"]
    }
  ])

  tags = {
    Name = "${var.name_prefix}-worker-task"
  }
}

# --- OTEL Collector ---
resource "aws_ecs_task_definition" "otel_collector" {
  family                   = "${var.name_prefix}-otel-collector"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "otel-collector"
      image     = var.otel_collector_image
      essential = true

      portMappings = [
        { containerPort = 4317, protocol = "tcp" },
        { containerPort = 4318, protocol = "tcp" },
        { containerPort = 8889, protocol = "tcp" },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.otel_collector.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.name_prefix}-otel-collector-task"
  }
}

# --- Jaeger ---
resource "aws_ecs_task_definition" "jaeger" {
  family                   = "${var.name_prefix}-jaeger"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "jaeger"
      image     = "jaegertracing/all-in-one:latest"
      essential = true

      portMappings = [
        { containerPort = 16686, protocol = "tcp" },
        { containerPort = 4317, protocol = "tcp" },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.jaeger.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.name_prefix}-jaeger-task"
  }
}

# --- Prometheus ---
resource "aws_ecs_task_definition" "prometheus" {
  family                   = "${var.name_prefix}-prometheus"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "prometheus"
      image     = var.prometheus_image
      essential = true

      portMappings = [
        { containerPort = 9090, protocol = "tcp" },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.prometheus.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.name_prefix}-prometheus-task"
  }
}

# --- Grafana ---
resource "aws_ecs_task_definition" "grafana" {
  family                   = "${var.name_prefix}-grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana:latest"
      essential = true

      portMappings = [
        { containerPort = 3000, protocol = "tcp" },
      ]

      environment = [
        { name = "GF_SECURITY_ADMIN_PASSWORD", value = "admin" },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.name_prefix}-grafana-task"
  }
}

# ──────────────────────────────────────────────
# ECS Services
# ──────────────────────────────────────────────

resource "aws_ecs_service" "backend" {
  name            = "${var.name_prefix}-backend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 8000
  }

  service_registries {
    registry_arn = aws_service_discovery_service.backend.arn
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Name = "${var.name_prefix}-backend-service"
  }
}

resource "aws_ecs_service" "frontend" {
  name            = "${var.name_prefix}-frontend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Name = "${var.name_prefix}-frontend-service"
  }
}

resource "aws_ecs_service" "worker" {
  name            = "${var.name_prefix}-worker"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  tags = {
    Name = "${var.name_prefix}-worker-service"
  }
}

resource "aws_ecs_service" "otel_collector" {
  name            = "${var.name_prefix}-otel-collector"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.otel_collector.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.otel_collector.arn
  }

  tags = {
    Name = "${var.name_prefix}-otel-collector-service"
  }
}

resource "aws_ecs_service" "jaeger" {
  name            = "${var.name_prefix}-jaeger"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.jaeger.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.jaeger.arn
    container_name   = "jaeger"
    container_port   = 16686
  }

  service_registries {
    registry_arn = aws_service_discovery_service.jaeger.arn
  }

  depends_on = [aws_lb_listener.jaeger]

  tags = {
    Name = "${var.name_prefix}-jaeger-service"
  }
}

resource "aws_ecs_service" "prometheus" {
  name            = "${var.name_prefix}-prometheus"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.prometheus.arn
    container_name   = "prometheus"
    container_port   = 9090
  }

  depends_on = [aws_lb_listener.prometheus]

  tags = {
    Name = "${var.name_prefix}-prometheus-service"
  }
}

resource "aws_ecs_service" "grafana" {
  name            = "${var.name_prefix}-grafana"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.grafana]

  tags = {
    Name = "${var.name_prefix}-grafana-service"
  }
}
