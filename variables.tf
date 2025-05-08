variable "aws_region" {
  description = "AWS region where this is deployed"
  type        = string
}

variable "aws_az" {
  description = "AWS AZ where this is deployed"
  type        = string
}

variable "domain_name" {
  description = "The name of domain"
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

variable "mysql_username" {
  description = "The name of mysql user"
  type        = string
}

variable "mysql_password" {
  description = "The password of mysql user"
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

variable "s3_drs_bucket_name" {
  description = "S3 DRS bucket name"
  type        = string
}

variable "secret_key_base" {
  description = "Secret Key Base"
  type        = string
}

