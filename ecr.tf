resource "aws_ecr_repository" "main" {
  name                 = "main-${local.name_suffix}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.symmetric.arn
  }
}

data "aws_ecr_lifecycle_policy_document" "main" {
  rule {
    priority    = 1
    description = "Keep the last 3 images that contain the 'latest' tag"

    selection {
      tag_status = "tagged"
      tag_prefix_list = [
        "frontend-latest",
        "backend-latest"
      ]
      count_type   = "imageCountMoreThan"
      count_number = 3
    }
    action {
      type = "expire"
    }
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name
  policy     = data.aws_ecr_lifecycle_policy_document.main.json
}

