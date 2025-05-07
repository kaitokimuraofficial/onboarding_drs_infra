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
    priority = 1
    selection {
      tag_status      = "tagged"
      tag_prefix_list = ["frontend-"]
      count_type      = "imageCountMoreThan"
      count_number    = 3
    }
    action {
      type = "expire"
    }
  }

  rule {
    priority = 2
    selection {
      tag_status      = "tagged"
      tag_prefix_list = ["backend-"]
      count_type      = "imageCountMoreThan"
      count_number    = 3
    }
    action {
      type = "expire"
    }
  }

  rule {
    priority = 3
    selection {
      tag_status   = "untagged"
      count_type   = "imageCountMoreThan"
      count_number = 1
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

