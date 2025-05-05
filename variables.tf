variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "environment" {
  description = "The name of environment"
  type        = string
}

variable "kk_account_id" {
  description = "The account ID of kk"
  type        = string
}

variable "kk_iam_user_arn" {
  description = "The ARN of kk"
  type        = string
}

variable "mysql_db_name" {
  description = "The name of initial database in MySQL instance"
  type        = string
}

variable "project_name" {
  description = "The name of project"
  type        = string
}

variable "s3_backend_bucket_name" {
  description = "S3 backend bucket name"
  type        = string
}

variable "secret_key_base" {
  description = "Secret Key Base"
  type        = string
}

