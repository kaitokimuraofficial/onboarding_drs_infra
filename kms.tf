resource "aws_kms_key" "symmetric" {
  description = "Symmetric encryption KMS key"

  enable_key_rotation     = true
  rotation_period_in_days = 90
}

/*
resource "aws_kms_key_policy" "symmetric" {
  key_id = aws_kms_key.symmetric.id
  policy = jsonencode({
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.kk_iam_user_arn}"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
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
*/
