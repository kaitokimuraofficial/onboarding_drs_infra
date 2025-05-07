locals {
  name_suffix = "${var.project_name}-${var.aws_az}-${var.environment}"
}

locals {
  public_subnets_1a = {
    "ingress" = {
      "az"   = "ap-northeast-1a",
      "cidr" = "10.0.0.0/24"
    },
    "bastion" = {
      "az"   = "ap-northeast-1a",
      "cidr" = "10.0.240.0/24"
    }
  }
  public_subnets_1c = {
    "ingress" = {
      "az"   = "ap-northeast-1c",
      "cidr" = "10.0.1.0/24"
    }
  }

  private_subnets_1a = {
    "ecs" = {
      "az"   = "ap-northeast-1a",
      "cidr" = "10.0.8.0/24"
    },
    "db" = {
      "az"   = "ap-northeast-1a",
      "cidr" = "10.0.16.0/24"
    },
    "egress" = {
      "az"   = "ap-northeast-1a",
      "cidr" = "10.0.242.0/24"
    }
  }
  private_subnets_1c = {
    "db" = {
      "az"   = "ap-northeast-1c",
      "cidr" = "10.0.17.0/24"
    }
  }
}

locals {
  interface = {
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

