resource "aws_service_discovery_http_namespace" "daily_report_system" {
  name        = "daily-report-system"
  description = "The namespace of development environment"
}

