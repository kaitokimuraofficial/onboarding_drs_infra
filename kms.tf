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
        Sid    = "Enable only myself to do everything"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.kk_iam_user_arn}"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow ECR to use the key"
        Effect = "Allow"
        Principal = {
          Service = "ecr.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow ECS to use this key"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ecs_task_exec.arn
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
    Version = "2012-10-17"
  })
}

