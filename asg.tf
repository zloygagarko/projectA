resource "aws_lb_target_group" "target_group" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

# resource "aws_lb_target_group_attachment" "tg_attachment" {
#   target_group_arn = aws_lb_target_group.target_group.arn
#   target_id = aws_instance.example.id
#   port = 80
# }

resource "aws_lb" "alb" {
  name               = "alb-1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sec.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]

  enable_deletion_protection = true

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.id
#     prefix  = "test-lb"
#     enabled = true
#   }

  tags = {
    Environment = var.env
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = "80"
  protocol = "HTTP"
    # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}


resource "aws_autoscaling_group" "asg" {
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  vpc_zone_identifier = [
    aws_subnet.private_subnets[0].id,
    aws_subnet.private_subnets[1].id,
    aws_subnet.private_subnets[2].id
  ]

  min_size           = 1
  max_size           = 99
  desired_capacity   = 1
  health_check_type  = "EC2"
  health_check_grace_period = 300
  target_group_arns = [aws_lb_target_group.target_group.arn]


  tag {
    key                 = "Name"
    value               = "example"
    propagate_at_launch = true
   }

}

# resource "aws_autoscaling_policy" "asg_policy" {
#   autoscaling_group_name = "asg"
#   name = "asg_policy_1"
#   policy_type = "TargetTrackingScaling"
#   target_tracking_configuration {
#     target_value = 55

#   }
resource "aws_route53_zone" "primary" {
  name = "zloygagarko.link"
}

resource "aws_route53_record" "record" {
  zone_id = aws_route53_zone.primary.id
  name = "www.zloygagarko.link"
  type = "CNAME"
  ttl = 300
  records = [aws_lb.alb.dns_name]
}