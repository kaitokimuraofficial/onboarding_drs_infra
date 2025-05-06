resource "aws_s3_bucket" "drs" {
  bucket = var.s3_drs_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.s3_drs_bucket_name}-${local.name_suffix}"
  }
}

