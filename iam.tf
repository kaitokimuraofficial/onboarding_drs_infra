resource "aws_iam_role" "drs_deploy_gha" {
  name               = "drs-deploy-github-actions"
  assume_role_policy = data.aws_iam_policy_document.drs_deploy_gha_assume_role_policy.json
}

data "aws_iam_policy_document" "drs_deploy_gha_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.kk_account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:kaitokimuraofficial/daily_report_system:ref:refs/heads/deploy",
      ]
    }
  }
}

resource "aws_iam_role_policy" "drs_deploy_gha" {
  role   = aws_iam_role.drs_deploy_gha.id
  policy = data.aws_iam_policy_document.drs_deploy_gha.json
}

data "aws_iam_policy_document" "drs_deploy_gha" {
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [
      aws_ecr_repository.main.arn,
    ]
  }
}

data "aws_iam_policy_document" "ecs_task_execution_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_execution" {
  role   = aws_iam_role.ecs_task_execution.id
  policy = data.aws_iam_policy.ecs_task_execution_role_policy.json
}

resource "aws_iam_role" "ecs_task_execution" {
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume.json

  tags = {
    Name = "ecs-task-execution-${local.name_suffix}"
  }
}

