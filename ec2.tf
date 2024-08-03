resource "aws_launch_template" "example" {
  name = var.launch_template_name

  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    subnet_id = aws_subnet.public_subnets[1].id
    security_groups = [ aws_security_group.ec2_sec.id ]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.env}-instance_from_template"
    }
  }
}

# resource "aws_instance" "example" {
#   launch_template {
#     id      = aws_launch_template.example.id
#     version = "$Latest"
#   }
# }

#===================================Sec_group===========================

resource "aws_security_group" "alb_sec" {
  name        = "alb_sec_group"
  description = "Allow HTTP and HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_http_https"
  }
}

# resource "aws_vpc_security_group_ingress_rule" "allow_HTTPS_ipv4" {
#   security_group_id = aws_security_group.alb_sec.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP_ipv4" {
  security_group_id = aws_security_group.alb_sec.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}



resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.alb_sec.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#========================

resource "aws_security_group" "ec2_sec" {
  name        = "ec2_sec_group"
  description = "Allow HTTP and HTTPS inbound traffic from ALB and all outbound traffic"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "allow_http_https_from_alb"
  }
}

# resource "aws_vpc_security_group_ingress_rule" "allow_HTTPS_ipv4_2" {
#   security_group_id = aws_security_group.ec2_sec.id
#   referenced_security_group_id = aws_security_group.alb_sec.id
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP" {    #TEMPORARY RULE
  security_group_id = aws_security_group.ec2_sec.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_SSH_ipv4" {    #TEMPORARY RULE
  security_group_id = aws_security_group.ec2_sec.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP_ipv4_2" {
  security_group_id = aws_security_group.ec2_sec.id
  referenced_security_group_id = aws_security_group.alb_sec.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}



resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_2" {
  security_group_id = aws_security_group.ec2_sec.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#===============================================================================

resource "aws_security_group" "rds_sec" {
  name        = "rds_sec_group"
  description = "Allow only inbound traffic from ec2_sec_group and all outbound traffic"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "allow_mysql_from_ec2"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql_aurora" {
  security_group_id = aws_security_group.rds_sec.id
  referenced_security_group_id = aws_security_group.ec2_sec.id
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_3" {
  security_group_id = aws_security_group.rds_sec.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#==============================IAM_S3_role==============================

# resource "aws_iam_role" "ec2_s3_role" {
#   name = "ec2_role"
#   assume_role_policy = jsonencode({
#     Version: "2012-10-17",
#     Statement: [
#     {
#       Effect: "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#       Action: "sts:AssumeRole"
#     }
#   ]
#   })

#   tags = {
#     tag-key = "name-s3_role"
#   }
# }

# resource "aws_iam_role_policy" "s3_role_policy" {
#   name   = "test_role_policy"
#   role   = aws_iam_role.ec2_s3_role.id
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = "s3:*"
#         Data = [
#           "arn:aws:s3:::zloygagarko",
#           "arn:aws:s3:::zloygagarko/*"
#         ]
#       }
#     ]
#   })
# }


# data "aws_s3_bucket" "s3_terraform" {
#   bucket = "zloygagarko"
# }

resource "aws_iam_policy" "s3policy" {
  name        = "s3policy"
  description = "Policy for S3 access"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid     = "Stmt1722696952726"
        Effect  = "Allow"
        Action  = "s3:GetObject"
        Resource = "arn:aws:s3:::zloygagarko/"  # Note: Added / to include objects in the bucket
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example_policy_attachment" {
  role       = aws_iam_role.iamrole.name
  policy_arn  = aws_iam_policy.s3policy.arn
}

resource "aws_iam_role" "iamrole" {
  name = "iamrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "s3_role_access" {
  name = "s3_profile"
  role = aws_iam_role.iamrole.name
}

# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

#====================================================================================