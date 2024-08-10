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

resource "aws_rds_cluster" "wordpress" {
  cluster_identifier        = "rds-cluster"
  database_name = "wordpress"
  engine                    = "mysql"
  engine_version = "8.0.32"
  db_cluster_instance_class = "db.m5d.large"
  storage_type              = "gp3"
  iops = 3000
  allocated_storage         = 20
  master_username           = "admin"
  master_password           = "Admin12345"
  vpc_security_group_ids  = [aws_security_group.rds_sec.id]
  db_subnet_group_name    = aws_db_subnet_group.db_group.name
}


