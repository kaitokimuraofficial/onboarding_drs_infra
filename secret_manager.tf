resource "aws_secretsmanager_secret" "secret_key_base" {
  name        = "prod/drs/secret_key_base"
  description = "SECRET_KEY_BASE for DRS prod"
  kms_key_id  = aws_kms_key.symmetric.arn
}

resource "aws_secretsmanager_secret_version" "secret_key_base" {
  secret_id = aws_secretsmanager_secret.secret_key_base.id
  secret_string = jsonencode({
    SECRET_KEY_BASE = var.secret_key_base
  })
}

