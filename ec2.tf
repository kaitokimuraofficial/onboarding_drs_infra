resource "aws_instance" "bastion" {
  ami                         = "ami-0c2da9ee6644f16e5"
  instance_type               = "t2.nano"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.private_1a["bastion"].id
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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion_eic_endpoint" {
  name   = "bastion-eic-endpoint-${local.name_suffix}"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress = []
}

resource "aws_ec2_instance_connect_endpoint" "for_bastion_eic" {
  subnet_id          = aws_subnet.private_1a["bastion"].id
  security_group_ids = [aws_security_group.bastion_eic_endpoint.id]
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
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ecs_service.id]
  }
}

resource "aws_lb_target_group" "frontend" {
  name        = "drs-1a-prod"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "backend" {
  name        = "drs-backend-1a-prod"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  port        = 3000
  protocol    = "HTTP"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb" "alb" {
  name               = "drs-application"
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.alb.id]

  subnets = [
    aws_subnet.public_1a["ingress"].id,
    aws_subnet.public_1c["ingress"].id
  ]
}

resource "aws_lb_listener" "alb_default" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.my_domain.arn

  default_action {
    target_group_arn = aws_lb_target_group.frontend.id
    type             = "forward"
  }
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "3000"
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.my_domain.arn

  default_action {
    target_group_arn = aws_lb_target_group.backend.id
    type             = "forward"
  }
}

