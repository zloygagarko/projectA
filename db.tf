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

# resource "aws_db_instance" "default" {
#   allocated_storage    = 10
#   db_name              = "project_db"
#   engine               = "mysql"
#   engine_version       = "8.0"
#   instance_class       = "db.t3.micro"
#   username             = "admin"
#   password             = "Admin12345"
#   db_subnet_group_name = aws_db_subnet_group.db_group.name
#   vpc_security_group_ids = [ aws_security_group.rds_sec.id ]
#   parameter_group_name = "default.mysql8.0"
#   skip_final_snapshot  = true
# }

resource "aws_rds_cluster" "wordpress" {
  cluster_identifier      = "rds-cluster"
  engine                  = "mysql" # Adjust if needed
  master_username         = "admin"
  master_password         = "Admin12345" # Use Secrets Manager for sensitive data
  database_name           = "wordpress"
  backup_retention_period = 7
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.rds_sec.id]
  db_subnet_group_name    = aws_db_subnet_group.db_group.name
}

resource "aws_rds_cluster_instance" "writer" {
  count                  = 1
  cluster_identifier     = aws_rds_cluster.wordpress.id
  instance_class         = "db.t3.micro"
  engine                 = aws_rds_cluster.wordpress.engine
  publicly_accessible    = false
}

resource "aws_rds_cluster_instance" "reader" {
  count                  = 3
  cluster_identifier     = aws_rds_cluster.wordpress.id
  instance_class         = "db.t3.micro"
  engine                 = aws_rds_cluster.wordpress.engine
  publicly_accessible    = false
}