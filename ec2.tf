resource "aws_instance" "bastion" {
  ami                         = "ami-0c2da9ee6644f16e5"
  instance_type               = "t2.nano"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public["public-ne-1a"].id
  tenancy                     = "default"

  user_data = file("${path.module}/scripts/user_data.sh")

  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

  tags = {
    Name = "bastion-${local.name_suffix}"
  }
}

resource "aws_security_group" "bastion" {
  name   = "bastion-${local.name_suffix}"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ec2_instance_connect_endpoint" "for_bastion_eic" {
  subnet_id          = aws_subnet.public["public-ne-1a"].id
  security_group_ids = [aws_security_group.bastion.id]
  preserve_client_ip = true
}

resource "aws_security_group" "alb" {
  name   = "alb-${local.name_suffix}"
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

resource "aws_lb_target_group" "frontend" {
  name   = "frontend-${local.name_suffix}"
  vpc_id = aws_vpc.main.id

  port     = 80
  protocol = "HTTP"
}

resource "aws_lb" "alb" {
  name               = "drs-application"
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.alb.id]

  subnets = [
    aws_subnet.public["public-ne-1a"].id,
    aws_subnet.public["public-ne-1c"].id
  ]

  access_logs {
    enabled = true
    bucket  = aws_s3_bucket.drs.id
    prefix  = "/logs/drs/access"
  }

  connection_logs {
    enabled = true
    bucket  = aws_s3_bucket.drs.id
    prefix  = "/logs/drs/connection"
  }
}

resource "aws_lb_listener" "alb_default" {
  load_balancer_arn = aws_lb.alb.id

  default_action {
    target_group_arn = aws_lb_target_group.frontend.id
    type             = "forward"
  }
}

