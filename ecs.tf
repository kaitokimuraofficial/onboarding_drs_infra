resource "aws_service_discovery_http_namespace" "daily_report_system" {
  name        = "daily-report-system"
  description = "The namespace of development environment"
}

resource "aws_ecs_cluster" "main" {
  name = "main-${local.name_suffix}"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.symmetric.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.daily_report_system.name
      }
    }
  }

  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.daily_report_system.arn
  }
}
