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

resource "aws_instance" "example" {
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
}

#===================================Sec_group===========================

resource "aws_security_group" "alb_sec" {
  name        = "alb_sec_group"
  description = "Allow HTTP and HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_http_https"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTPS_ipv4" {
  security_group_id = aws_security_group.alb_sec.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

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

resource "aws_vpc_security_group_ingress_rule" "allow_HTTPS_ipv4_2" {
  security_group_id = aws_security_group.ec2_sec.id
  referenced_security_group_id = aws_security_group.alb_sec.id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
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

#=========================================
