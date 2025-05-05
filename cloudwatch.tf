resource "aws_cloudwatch_log_group" "daily_report_system" {
  name              = "/daily_report_system"
  retention_in_days = 1

  tags = {
    Environment = "prod"
  }
}

