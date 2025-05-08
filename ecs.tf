resource "aws_service_discovery_http_namespace" "drs" {
  name        = "daily-report-system"
  description = "The namespace of development environment"
}

resource "aws_ecs_cluster" "main" {
  name = "main-${local.name_suffix}"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.symmetric.arn
      logging    = "DEFAULT"
    }
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.drs.arn
  }
}

resource "aws_ecs_task_definition" "daily_report_system" {
  family                   = "daily_report_system"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_exec.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${aws_ecr_repository.main.repository_url}:frontend-latest@sha256:811c0bed670bc9e428458aa6905491294ef1a7b324ce27398bd6aad45134729a"
      cpu       = 0
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      command = ["nginx", "-g", "daemon off;"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = aws_cloudwatch_log_group.daily_report_system.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "prod"
        }
      }
    },
    {
      name      = "backend"
      image     = "${aws_ecr_repository.main.repository_url}:backend-latest@sha256:870fb97500a42d721dcf39290ddb6b107f8549368490d027f78ebf52208955f5"
      cpu       = 0
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        { name = "RAILS_ENV", value = "production" },
        { name = "DB_NAME", value = var.mysql_db_name },
        { name = "DB_HOST", value = aws_db_instance.mysql.address },
        { name = "DB_PORT", value = "3306" }
      ]
      secrets = [
        {
          name      = "SECRET_KEY_BASE",
          valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${var.kk_account_id}:secret:${aws_secretsmanager_secret.backend_task.name}:SECRET_KEY_BASE::"
        },
        {
          name      = "DB_USERNAME"
          valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${var.kk_account_id}:secret:${aws_secretsmanager_secret.backend_task.name}:DB_USERNAME::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${var.kk_account_id}:secret:${aws_secretsmanager_secret.backend_task.name}:DB_PASSWORD::"
        }
      ]
      command = ["/bin/sh", "-c", "RAILS_ENV=production bundle exec rake db:setup_seed && RAILS_ENV=production bundle exec rails s -b 0.0.0.0"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = aws_cloudwatch_log_group.daily_report_system.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "prod"
        }
      }
    },
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_security_group" "ecs_service" {
  name   = "ecs-service-${local.name_suffix}"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "daily_report_system" {
  name                   = local.name_suffix
  cluster                = aws_ecs_cluster.main.arn
  launch_type            = "FARGATE"
  desired_count          = 1
  enable_execute_command = true

  task_definition = aws_ecs_task_definition.daily_report_system.arn

  network_configuration {
    subnets         = [aws_subnet.private_1a["ecs"].id]
    security_groups = [aws_security_group.ecs_service.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 80
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 3000
  }
}

