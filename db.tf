resource "aws_db_subnet_group" "db_group" {
  name       = "db_subnet_group"
  subnet_ids = [
    aws_subnet.private_subnets[0].id,
    aws_subnet.private_subnets[1].id,
    aws_subnet.private_subnets[2].id  
  ]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "project_db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "admin12345"
  db_subnet_group_name = aws_db_subnet_group.db_group.name
  vpc_security_group_ids = [ aws_security_group.rds_sec.id ]
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}