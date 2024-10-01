resource "aws_lb" "elb" {
  for_each           = var.public_vpc_subnets
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_app_vpc.id, aws_security_group.elb_sg.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]

  tags = local.common_tags
}

resource "aws_lb_listener" "front_end" {
  for_each          = aws_lb.elb               # Ensure it loops over each load balancer
  load_balancer_arn = aws_lb.elb[each.key].arn # Refer to the specific load balancer instance
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  tags = local.common_tags
}

resource "aws_lb_target_group" "target_group" {
  name     = var.tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  tags = local.common_tags
}

resource "aws_lb_target_group_attachment" "tg-attachment" {
  for_each         = aws_instance.app_server
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = each.value.id
  port             = 80

  # Explicitly add depends_on to avoid timing issues
  depends_on = [aws_lb_target_group.target_group, aws_instance.app_server]
}