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

resource "aws_ecs_task_definition" "daily_report_system" {
  family                   = "daily_report_system"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  network_mode             = "awsvpc"

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${aws_ecr_repository.main.arn}:backend-latest"
      cpu       = 0
      essential = true
      portMappings = [
        {
          containerPort = 5173
          hostPort      = 5173
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.daily_report_system.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "prod"
        }
      }
    },
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_ecs_service" "daily_report_system" {
  name        = "daily-report-system-${local.name_suffix}"
  cluster     = aws_ecs_cluster.main.arn
  launch_type = "FARGATE"

  task_definition = aws_ecs_task_definition.daily_report_system.arn

  network_configuration {
    subnets = [
      aws_subnet.private["private-ne-1a"].id,
      aws_subnet.private["private-ne-1c"].id
    ]
  }
}
