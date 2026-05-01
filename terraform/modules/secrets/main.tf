# ──────────────────────────────────────────────
# Secrets Manager — Application Secrets
# ──────────────────────────────────────────────

resource "aws_secretsmanager_secret" "openai_api_key" {
  name                    = "${var.name_prefix}/openai-api-key"
  description             = "OpenAI API key for RAG system"
  recovery_window_in_days = 7

  tags = {
    Name = "${var.name_prefix}-openai-api-key"
  }
}

resource "aws_secretsmanager_secret_version" "openai_api_key" {
  secret_id     = aws_secretsmanager_secret.openai_api_key.id
  secret_string = var.openai_api_key
}

resource "aws_secretsmanager_secret" "pinecone_api_key" {
  name                    = "${var.name_prefix}/pinecone-api-key"
  description             = "Pinecone API key for vector store"
  recovery_window_in_days = 7

  tags = {
    Name = "${var.name_prefix}-pinecone-api-key"
  }
}

resource "aws_secretsmanager_secret_version" "pinecone_api_key" {
  secret_id     = aws_secretsmanager_secret.pinecone_api_key.id
  secret_string = var.pinecone_api_key
}

resource "aws_secretsmanager_secret" "jwt_secret_key" {
  name                    = "${var.name_prefix}/jwt-secret-key"
  description             = "JWT secret key for authentication"
  recovery_window_in_days = 7

  tags = {
    Name = "${var.name_prefix}-jwt-secret-key"
  }
}

resource "aws_secretsmanager_secret_version" "jwt_secret_key" {
  secret_id     = aws_secretsmanager_secret.jwt_secret_key.id
  secret_string = var.jwt_secret_key
}

resource "aws_secretsmanager_secret" "pinecone_index" {
  name                    = "${var.name_prefix}/pinecone-index"
  description             = "Pinecone index name"
  recovery_window_in_days = 7

  tags = {
    Name = "${var.name_prefix}-pinecone-index"
  }
}

resource "aws_secretsmanager_secret_version" "pinecone_index" {
  secret_id     = aws_secretsmanager_secret.pinecone_index.id
  secret_string = var.pinecone_index
}
