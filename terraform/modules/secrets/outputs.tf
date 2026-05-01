output "secret_arns" {
  description = "Map of secret ARNs"
  value = {
    openai_api_key   = aws_secretsmanager_secret.openai_api_key.arn
    pinecone_api_key = aws_secretsmanager_secret.pinecone_api_key.arn
    pinecone_index   = aws_secretsmanager_secret.pinecone_index.arn
    jwt_secret_key   = aws_secretsmanager_secret.jwt_secret_key.arn
  }
}
