resource "aws_s3_bucket" "drs" {
  bucket = var.s3_drs_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.s3_drs_bucket_name}-${local.name_suffix}"
  }
}

resource "aws_s3_bucket_policy" "drs" {
  bucket = aws_s3_bucket.drs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::582318560864:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.drs.arn}/*"
      }
    ]
  })
}

