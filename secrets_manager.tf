resource "aws_secretsmanager_secret" "backend_task" {
  name       = "drs/backend"
  kms_key_id = aws_kms_key.symmetric.arn
}

resource "aws_secretsmanager_secret_version" "backend_task" {
  secret_id = aws_secretsmanager_secret.backend_task.id
  secret_string = jsonencode({
    SECRET_KEY_BASE = var.secret_key_base
    DB_USERNAME     = var.mysql_username
    DB_PASSWORD     = var.mysql_password
  })
}

