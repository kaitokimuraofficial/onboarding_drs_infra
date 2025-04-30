resource "aws_ecr_repository" "main" {
  name                 = "main-${local.name_suffix}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.symmetric.id
  }
}
