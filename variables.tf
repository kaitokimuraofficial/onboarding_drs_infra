variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "environment" {
  description = "The name of environment"
  type        = string
}

variable "s3_backend_bucket_name" {
  description = "S3 backend bucket name"
  type        = string
}
