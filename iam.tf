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

