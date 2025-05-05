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

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
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

resource "aws_vpc_endpoint" "private_subnets" {
  for_each = local.endpoints

  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = each.value["type"]
  service_name      = each.value["sn"]

  subnet_ids = each.value["type"] == "Interface" ? [
    aws_subnet.private["private-ne-1a"].id,
    aws_subnet.private["private-ne-1c"].id
  ] : null

  route_table_ids = each.value["type"] == "Gateway" ? [
    aws_route_table.main.id
  ] : null

  private_dns_enabled = each.value["type"] == "Interface"

  tags = {
    Name = "${each.key}-${local.name_suffix}"
  }
}

resource "aws_vpc_endpoint_security_group_association" "ecr_api" {
  vpc_endpoint_id   = aws_vpc_endpoint.private_subnets["ecr-api"].id
  security_group_id = aws_security_group.ecr_api.id
}

resource "aws_vpc_endpoint_policy" "ecr_api" {
  vpc_endpoint_id = aws_vpc_endpoint.private_subnets["ecr-api"].id
  policy          = data.aws_iam_policy_document.ecr_api.json
}

resource "aws_vpc_endpoint_security_group_association" "ecr_dkr" {
  vpc_endpoint_id   = aws_vpc_endpoint.private_subnets["ecr-dkr"].id
  security_group_id = aws_security_group.ecr_dkr.id
}

resource "aws_vpc_endpoint_policy" "ecr_dkr" {
  vpc_endpoint_id = aws_vpc_endpoint.private_subnets["ecr-dkr"].id
  policy          = data.aws_iam_policy_document.ecr_dkr.json
}

resource "aws_vpc_endpoint_policy" "s3" {
  vpc_endpoint_id = aws_vpc_endpoint.private_subnets["s3"].id
  policy          = data.aws_iam_policy_document.s3.json
}

