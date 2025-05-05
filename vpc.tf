resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "main-${local.name_suffix}"
  }
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value["cidr"]
  availability_zone       = each.value["az"]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-${each.key}-${local.name_suffix}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-${local.name_suffix}"
  }
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private["private-ne-1a"].id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private["private-ne-1c"].id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "ecr_dkr" {
  description = "For VPC Endpoint of ecr.dkr"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private["private-ne-1a"].cidr_block,
      aws_subnet.private["private-ne-1c"].cidr_block
    ]
  }

  tags = {
    Name = "ecr-dkr-${local.name_suffix}"
  }
}

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

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type = "Interface"

  policy = data.aws_iam_policy_document.ecr_dkr.json

  subnet_ids = [
    aws_subnet.private["private-ne-1a"].id,
    aws_subnet.private["private-ne-1c"].id
  ]
  security_group_ids = [
    aws_security_group.ecr_dkr.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "ecr-dkr-${local.name_suffix}"
  }
}

resource "aws_security_group" "ecr_api" {
  description = "For VPC Endpoint of ecr.api"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private["private-ne-1a"].cidr_block,
      aws_subnet.private["private-ne-1c"].cidr_block
    ]
  }

  tags = {
    Name = "ecr-api-${local.name_suffix}"
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

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type = "Interface"

  policy = data.aws_iam_policy_document.ecr_api.json

  subnet_ids = [
    aws_subnet.private["private-ne-1a"].id,
    aws_subnet.private["private-ne-1c"].id
  ]
  security_group_ids = [
    aws_security_group.ecr_api.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "ecr-api-${local.name_suffix}"
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

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"

  policy = data.aws_iam_policy_document.s3.json

  route_table_ids = [
    aws_route_table.main.id
  ]

  tags = {
    Name = "s3-${local.name_suffix}"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private["private-ne-1a"].id,
    aws_subnet.private["private-ne-1c"].id
  ]

  private_dns_enabled = true

  tags = {
    Name = "logs-${local.name_suffix}"
  }
}

resource "aws_vpc_endpoint" "secret_manager" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.secretsmanager"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private["private-ne-1a"].id,
    aws_subnet.private["private-ne-1c"].id
  ]

  private_dns_enabled = true

  tags = {
    Name = "secret-manager-${local.name_suffix}"
  }
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private["private-ne-1a"].id,
    aws_subnet.private["private-ne-1c"].id
  ]

  private_dns_enabled = true

  tags = {
    Name = "ssm-messages-${local.name_suffix}"
  }
}

