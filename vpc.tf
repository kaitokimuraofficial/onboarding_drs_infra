resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "main-${local.name_suffix}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-${local.name_suffix}"
  }
}

resource "aws_subnet" "public_1a" {
  for_each = local.public_subnets_1a

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.value["az"]
  cidr_block              = each.value["cidr"]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${each.key}-${local.name_suffix}"
  }
}

resource "aws_subnet" "private_1a" {
  for_each = local.private_subnets_1a

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.value["az"]
  cidr_block              = each.value["cidr"]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-${each.key}-${local.name_suffix}"
  }
}

resource "aws_subnet" "private_1c" {
  for_each = local.private_subnets_1c

  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.value["az"]
  cidr_block              = each.value["cidr"]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-${each.key}-drs-ap-northeast-1c-prod"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public-${local.name_suffix}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private-${local.name_suffix}"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public_1a

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_1a["ecs"].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "interface" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private_1a["ecs"].cidr_block]
  }

  tags = {
    Name = "interface-${local.name_suffix}"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface

  vpc_id              = aws_vpc.main.id
  vpc_endpoint_type   = "Interface"
  service_name        = each.value["sn"]
  private_dns_enabled = true

  subnet_ids = [aws_subnet.private_1a["egress"].id]

  security_group_ids = [aws_security_group.interface.id]

  tags = {
    Name = "${each.key}-${local.name_suffix}"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.main.id

  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.ap-northeast-1.s3"

  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name = "s3-${local.name_suffix}"
  }
}

resource "aws_vpc_endpoint_policy" "s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : "*"
      }
    ]
  })
}

/*
resource "aws_security_group" "ssh" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-${local.name_suffix}"
  }
}

resource "aws_vpc_endpoint_security_group_association" "ssm" {
  vpc_endpoint_id   = aws_vpc_endpoint.private_subnets["ssm"].id
  security_group_id = aws_security_group.ssh.id
}

resource "aws_vpc_endpoint_security_group_association" "ssm_messages" {
  vpc_endpoint_id   = aws_vpc_endpoint.private_subnets["ssm-messages"].id
  security_group_id = aws_security_group.ssh.id
}
*/
