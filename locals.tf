locals {
  name_suffix = "${var.project_name}-${var.aws_region}-${var.environment}"
}

locals {
  private_subnets = {
    "private-ne-1a" = { "az" = "ap-northeast-1a", "cidr" = "10.0.96.0/20" },
    "private-ne-1c" = { "az" = "ap-northeast-1c", "cidr" = "10.0.192.0/20" },
  }
}
