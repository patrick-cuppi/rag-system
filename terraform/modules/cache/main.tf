# ──────────────────────────────────────────────
# ElastiCache Subnet Group
# ──────────────────────────────────────────────

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name_prefix}-cache-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name_prefix}-cache-subnet-group"
  }
}

# ──────────────────────────────────────────────
# ElastiCache Redis (single node to save cost)
# ──────────────────────────────────────────────

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.name_prefix}-redis"
  engine               = "redis"
  engine_version       = "7.1"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [var.elasticache_security_group_id]

  snapshot_retention_limit = 1

  tags = {
    Name = "${var.name_prefix}-redis"
  }
}
