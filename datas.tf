data "aws_iam_policy_document" "drs_deploy_gha_assume" {
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
      values   = ["repo:kaitokimuraofficial/daily_report_system:ref:refs/heads/deploy"]
    }
  }
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
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [aws_ecr_repository.main.arn]
  }
}

data "aws_iam_policy_document" "ecs_task_exec_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_task_exec" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${var.kk_account_id}:secret:backend*",
      aws_kms_key.symmetric.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "events:PutRule",
      "events:PutTargets",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "events:DescribeRule",
      "events:ListTargetsByRule",
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.kk_account_id}:log-group:/aws/ecs/${aws_cloudwatch_log_group.daily_report_system.name}:*"
    ]
  }
}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:ecs:${var.aws_region}:${var.kk_account_id}:*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.kk_account_id]
    }
  }
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}
/*
data "aws_iam_policy_document" "ecr_dkr" {
  statement {
    principals {
      identifiers = ["*"]
      type        = "*"
    }

    actions = [
      "*"
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "ecr_api" {
  statement {
    principals {
      identifiers = ["*"]
      type        = "*"
    }

    actions = [
      "*"
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    principals {
      identifiers = ["*"]
      type        = "*"
    }

    actions = [
      "*"
    ]

    resources = [
      "*"
    ]
  }
}
*/

