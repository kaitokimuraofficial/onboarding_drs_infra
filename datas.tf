data "aws_iam_openid_connect_provider" "github_actions" {
  arn = "arn:aws:iam::${var.kk_account_id}:oidc-provider/token.actions.githubusercontent.com"
}

