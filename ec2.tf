resource "aws_launch_template" "example" {
  name = var.launch_template_name

  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
#   security_group_names   = [ var.sec_group_name ]
  vpc_security_group_ids = [aws_security_group.allow_http_https.id]

#   network_interfaces {
#     associate_public_ip_address = false
#     subnet_id = aws_subnet.private_subnets[0].id
#   }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.env}-instance_template"
    }
  }
}

resource "aws_instance" "example" {
#   count             = var.instance_count
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
}

#===================================Sec_group===========================

resource "aws_security_group" "allow_http_https" {
  name        = var.sec_group_name
  description = "Allow HTTP and HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_http_https"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTPS_ipv4" {
  security_group_id = aws_security_group.allow_http_https.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP_ipv4" {
  security_group_id = aws_security_group.allow_http_https.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}



resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_http_https.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
