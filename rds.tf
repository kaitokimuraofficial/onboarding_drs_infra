/*
resource "aws_db_subnet_group" "mysql" {
  name = "mysql-${local.name_suffix}"

  subnet_ids = [
    aws_subnet.private["private-ne-1a"].id,
    aws_subnet.private["private-ne-1c"].id
  ]
}

resource "aws_security_group" "mysql" {
  description = "For MySQL DB instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.public["public-ne-1a"].cidr_block,
      aws_subnet.private["private-ne-1a"].cidr_block,
      aws_subnet.private["private-ne-1c"].cidr_block
    ]
  }
}

resource "aws_db_instance" "mysql" {
  instance_class                = "db.t3.micro"
  allocated_storage             = 10
  db_name                       = var.mysql_db_name
  engine                        = "mysql"
  engine_version                = "8.4.5"
  username                      = "admin"
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.symmetric.key_id
  db_subnet_group_name          = aws_db_subnet_group.mysql.name
  vpc_security_group_ids        = [aws_security_group.mysql.id]
  multi_az                      = false
  auto_minor_version_upgrade    = false
}
*/

