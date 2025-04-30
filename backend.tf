terraform {
  backend "s3" {
    key          = "state/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}

resource "aws_s3_bucket" "backend" {
  bucket = var.s3_backend_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.s3_backend_bucket_name}-${local.name_suffix}"
  }
}
