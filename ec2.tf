resource "aws_instance" "bastion" {
  ami                         = "ami-0c2da9ee6644f16e5"
  instance_type               = "t2.nano"
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.public["public-ne-1a"].id
  tenancy                     = "default"
  iam_instance_profile        = aws_iam_instance_profile.ssm_bastion.name

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
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.public["public-ne-1a"].cidr_block,
      aws_subnet.public["public-ne-1c"].cidr_block
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

