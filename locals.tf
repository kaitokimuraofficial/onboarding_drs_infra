locals {
  name_suffix = "${var.project_name}-${var.aws_az}-${var.environment}"
}

locals {
  public_subnets = {
    "public-ne-1a" = {
      "az"   = "ap-northeast-1a",
      "cidr" = "10.0.0.0/20"
    },
    "public-ne-1c" = {
      "az"   = "ap-northeast-1c",
      "cidr" = "10.0.16.0/20"
    }
  }

  private_subnets = {
    "private-ne-1a" = {
      "az"   = "ap-northeast-1a",
      "cidr" = "10.0.96.0/20"
    },
    "private-ne-1c" = {
      "az"   = "ap-northeast-1c",
      "cidr" = "10.0.192.0/20"
    },
  }
}

locals {
  endpoints = {
    "ecr-api" = {
      "type" = "Interface",
      "sn"   = "com.amazonaws.ap-northeast-1.ecr.api"
    },
    "ecr-dkr" = {
      "type" = "Interface",
      "sn"   = "com.amazonaws.ap-northeast-1.ecr.dkr"
    },
    "logs" = {
      "type" = "Interface",
      "sn"   = "com.amazonaws.ap-northeast-1.logs"
    },
    "s3" = {
      "type" = "Gateway",
      "sn"   = "com.amazonaws.ap-northeast-1.s3"
    },
    "secrets-manager" = {
      "type" = "Interface",
      "sn"   = "com.amazonaws.ap-northeast-1.secretsmanager"
    },
    "ssm" = {
      "type" = "Interface",
      "sn"   = "com.amazonaws.ap-northeast-1.ssm"
    },
    "ssm-messages" = {
      "type" = "Interface",
      "sn"   = "com.amazonaws.ap-northeast-1.ssmmessages"
    }
  }
}

