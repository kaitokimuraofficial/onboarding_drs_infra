resource "aws_kms_key" "symmetric" {
  description = "Symmetric encryption KMS key"
}

resource "aws_kms_alias" "symmetric_alias" {
  name          = "alias/symmetric-${local.name_suffix}"
  target_key_id = aws_kms_key.symmetric.key_id
}

resource "aws_kms_key_policy" "symmetric" {
  key_id = aws_kms_key.symmetric.id
  policy = jsonencode({
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }

        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
}
